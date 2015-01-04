
import Foundation
import MapKit

let kISODateFormat = "YYYY-MM-dd\'T\'HH:mm:ss.SSS\'Z\'"

//let kAPIProtocol = "http://"
//let kAPIEndpoint = kAPIProtocol + "10.0.1.55:3000"

// Debug
//let kAPIProtocol = "https://"
//let kAPIEndpoint = kAPIProtocol + "fareshout-dev-matejkramny.ngapp.io"

// Production
let kAPIProtocol = "https://"
let kAPIEndpoint = kAPIProtocol + "fareshout.c.nodegear.com"

let kGeocodeApiEndpoint = "https://maps.googleapis.com/maps/api/geocode/json"

let kNetworkDomainError = "Invalid Response"

var storage: SharedStorage = SharedStorage()
var currentUser: User?
var sessionCookie: String?
var queueRequests: Bool = false
var queuedRequests: [Request] = []
var didRequestForNotifications: Bool = false

var sharedGeolocationConnection: NSURLSessionDataTask? = nil

class Request: NSObject {
	var request: NSMutableURLRequest
	var callback: (err: NSError?, data: AnyObject?) -> Void
	var body: NSData?
	
	init(request: NSMutableURLRequest, callback: (err: NSError?, data: AnyObject?) -> Void, body: NSData?) {
		self.request = request
		self.callback = callback
		self.body = body
		
		super.init()
	}
}

func makeRequest (endpoint: String, method: String?) -> NSMutableURLRequest {
	var request = NSMutableURLRequest(URL: NSURL(string: kAPIEndpoint + endpoint)!)
	request.setValue("application/json", forHTTPHeaderField: "Accept")
	request.setValue("application/json", forHTTPHeaderField: "Content-Type")
	if sessionCookie != nil {
		request.setValue(sessionCookie, forHTTPHeaderField: "Cookie")
	}
	
	request.HTTPShouldHandleCookies = true
	
	if method == nil {
		request.HTTPMethod = "GET"
	} else {
		request.HTTPMethod = method!
	}
	
	return request
}

func readSettings () -> Bool {
	var docDir = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as String
	
	var err: NSError?
	var contents = NSData(contentsOfFile: docDir + "/settings.json", options: NSDataReadingOptions.DataReadingMappedIfSafe, error: &err)
	
	if err != nil {
		return false
	}
	
	var settings: [String: AnyObject]? = NSJSONSerialization.JSONObjectWithData(contents!, options: NSJSONReadingOptions(0), error: &err) as? [String: AnyObject]
	if err != nil {
		return false
	}
	
	sessionCookie = settings!["sessionCookie"] as? String
	if settings!["user"] != nil {
		currentUser = User(_response: settings!["user"] as [String: AnyObject])
	}
	
	var reqForNotifs = settings!["didRequestForNotifications"] as? Bool
	if reqForNotifs != nil {
		didRequestForNotifications = reqForNotifs!
	}
	
	storage.accessToken = settings!["accessToken"] as? NSString
	
	return true
}

func saveSettings () -> Bool {
	var settings: [String: AnyObject] = [:]
	settings["sessionCookie"] = sessionCookie
	settings["user"] = currentUser?.json()
	settings["didRequestForNotifications"] = didRequestForNotifications
	settings["accessToken"] = storage.accessToken
	
	var docDir = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as String
	
	var err: NSError?
	var jsonData = NSJSONSerialization.dataWithJSONObject(settings, options: NSJSONWritingOptions.allZeros, error: &err)
	
	if err != nil {
		return false
	}
	
	jsonData?.writeToFile(docDir + "/settings.json", options: NSDataWritingOptions.AtomicWrite, error: &err)
	if err != nil {
		return false
	}
	
	return true
}

func checkLoggedIn () {
	if currentUser != nil {
		queueRequests = false
		currentUser?.register({ (error: NSError?, data: AnyObject?) -> Void in
			queueRequests = false
			unqueueRequests()
		})
		queueRequests = true
	}
}

func unqueueRequests() {
	for req in queuedRequests {
		if sessionCookie != nil {
			req.request.setValue(sessionCookie, forHTTPHeaderField: "Cookie")
		}
		
		doRequest(req.request, req.callback, req.body)
	}
	
	queuedRequests = []
}

func doPostRequest (request: NSMutableURLRequest, callback: (err: NSError?, data: AnyObject?) -> Void, body: [NSObject: AnyObject]) {
	var err: NSError?
	let data = NSJSONSerialization.dataWithJSONObject(body, options: nil, error: &err)
	
	doRequest(request, callback, data)
}

func callInMainThread (err: NSError?, data: AnyObject?, callback: (err: NSError?, data: AnyObject?) -> Void) {
	dispatch_async(dispatch_get_main_queue(), { () -> Void in
		callback(err:err, data: data)
	})
}

func doRequest (request: NSMutableURLRequest, callback: (err: NSError?, data: AnyObject?) -> Void, body: NSData?) -> NSURLSessionDataTask? {
	if queueRequests {
		var req: Request! = Request(request: request, callback: callback, body: body)
		queuedRequests.append(req)
		
		return nil
	}
	
	if body != nil {
		request.HTTPBody = body
	}
	
	let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data: NSData!, res: NSURLResponse!, err) -> Void in
		if err != nil {
			callInMainThread(err, nil, callback)
			return
		}
		
		var httpRes = res as NSHTTPURLResponse
		var cookie = httpRes.allHeaderFields["set-cookie"] as? String
		if cookie != nil {
			sessionCookie = cookie!.componentsSeparatedByString(";")[0] as String
		}
		
		var statusCode = httpRes.statusCode
		if statusCode >= 400 {
			callInMainThread(NSError(domain: kNetworkDomainError, code: 0, userInfo: nil), nil, callback)
			
			return
		}
		
		var jsonData: NSData = (NSString(data: data
			, encoding: NSUTF8StringEncoding)!).dataUsingEncoding(NSUTF8StringEncoding)!
		var e: NSError? = nil
		
		var json: AnyObject? = NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions(0), error: &e)
		if e != nil {
			callInMainThread(err, nil, callback)
			
			return
		}
		
		callInMainThread(nil, json, callback)
	}
	
	task.resume()
	
	return task
}

func findMessageList (to: NSString, callback: (list: MessageList?) -> Void) {
	MessageList.getLists({ (err: NSError?, data: [MessageList]) -> Void in
		var foundList: MessageList?
		
		for list in data {
			if to == list.receiver._id! || to == list.sender._id! {
				foundList = list
				break
			}
		}
		
		if foundList == nil {
			MessageList.createList(to, callback: { (err: NSError?, data: MessageList?) -> Void in
				if data != nil {
					callback(list: data!)
				}
			})
		} else {
			callback(list: foundList!)
		}
	})
}

func geocodeAddress(address: String, callback: (err: NSError?, data: [[NSString: AnyObject]]) -> Void) {
	if sharedGeolocationConnection != nil {
		sharedGeolocationConnection!.cancel()
		sharedGeolocationConnection = nil
	}
	
	var urlAddress = kGeocodeApiEndpoint + "?address=" + String(address.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!)
	var request = NSMutableURLRequest(URL: NSURL(string: urlAddress)!)
	request.setValue("application/json", forHTTPHeaderField: "Accept")
	request.HTTPMethod = "GET"
	
	sharedGeolocationConnection = doRequest(request, { (err: NSError?, data: AnyObject?) -> Void in
		if err != nil {
			return callback(err: err, data: [])
		}
		
		var json = data as? [NSString: AnyObject]
		if json == nil {
			return callback(err: nil, data: [])
		}
		
		let status = json!["status"] as NSString
		if status != "OK" {
			return callback(err: nil, data: [])
		}
		
		var results = json!["results"] as [[NSString: AnyObject]]
		callback(err: nil, data: results)
	}, nil)
}

func geocodeLocation(location: CLLocationCoordinate2D, callback: (err: NSError?, data: [[NSString: AnyObject]]) -> Void) {
	if sharedGeolocationConnection != nil {
		sharedGeolocationConnection!.cancel()
		sharedGeolocationConnection = nil
	}
	
	var urlAddress = NSString(format: "%@?latlng=%f,%f", kGeocodeApiEndpoint, location.latitude, location.longitude)
	var request = NSMutableURLRequest(URL: NSURL(string: urlAddress)!)
	request.setValue("application/json", forHTTPHeaderField: "Accept")
	request.HTTPMethod = "GET"
	
	sharedGeolocationConnection = doRequest(request, { (err: NSError?, data: AnyObject?) -> Void in
		if err != nil {
			return callback(err: err, data: [])
		}
		
		var json = data as? [NSString: AnyObject]
		if json == nil {
			return callback(err: nil, data: [])
		}
		
		let status = json!["status"] as NSString
		if status != "OK" {
			return callback(err: nil, data: [])
		}
		
		var results = json!["results"] as [[NSString: AnyObject]]
		callback(err: nil, data: results)
	}, nil)
}

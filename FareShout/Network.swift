
import Foundation

//let kAPIProtocol = "http://"
//let kAPIEndpoint = kAPIProtocol + "localhost:3000"

// Debug
let kAPIProtocol = "https://"
let kAPIEndpoint = kAPIProtocol + "fareshout-dev-matejkramny.ngapp.io"

// Production
//let kAPIProtocol = "https://"
//let kAPIEndpoint = kAPIProtocol + "fareshout-matejkramny.ngapp.io"

let kNetworkDomainError = "Invalid Response"

var storage: SharedStorage = SharedStorage()
var currentUser: User?
var sessionCookie: String?
var queueRequests: Bool = false
var queuedRequests: [Request] = []
var didRequestForNotifications: Bool = false

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
	
	return true
}

func saveSettings () -> Bool {
	var settings: [String: AnyObject] = [:]
	settings["sessionCookie"] = sessionCookie
	settings["user"] = currentUser?.json()
	settings["didRequestForNotifications"] = didRequestForNotifications
	
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

func doRequest (request: NSMutableURLRequest, callback: (err: NSError?, data: AnyObject?) -> Void, body: NSData?) {
	if queueRequests {
		var req: Request! = Request(request: request, callback: callback, body: body)
		queuedRequests.append(req)
		
		return
	}
	
	if body != nil {
		request.HTTPBody = body
	}
	
	let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data: NSData!, res: NSURLResponse!, err) -> Void in
		if err != nil {
			dispatch_async(dispatch_get_main_queue(), { () -> Void in
				callback(err: err, data: nil)
			})
			return
		}
		
		var httpRes = res as NSHTTPURLResponse
		var cookie = httpRes.allHeaderFields["set-cookie"] as? String
		if cookie != nil {
			sessionCookie = cookie!.componentsSeparatedByString(";")[0] as String
		}
		
		var statusCode = httpRes.statusCode
		if statusCode >= 400 {
			dispatch_async(dispatch_get_main_queue(), { () -> Void in
				callback(err: NSError(domain: kNetworkDomainError, code: 0, userInfo: nil), data: nil)
			})
			
			return
		}
		
		var jsonData: NSData = (NSString(data: data
			, encoding: NSUTF8StringEncoding)!).dataUsingEncoding(NSUTF8StringEncoding)!
		var e: NSError? = nil
		
		var json: AnyObject? = NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions(0), error: &e)
		if e != nil {
			dispatch_async(dispatch_get_main_queue(), { () -> Void in
				callback(err: err, data: nil)
			})
			return
		}
		
		dispatch_async(dispatch_get_main_queue(), { () -> Void in
			callback(err: nil, data: json)
		})
	}
	
	task.resume()
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

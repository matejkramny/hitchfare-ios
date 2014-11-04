
import Foundation

let kAPIProtocol = "http://"
let kAPIEndpoint = kAPIProtocol + "localhost:3000"

var currentUser: User?
var sessionCookie: String?

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
	
	return true
}

func saveSettings () -> Bool {
	var settings: [String: AnyObject] = [:]
	settings["sessionCookie"] = sessionCookie
	settings["user"] = currentUser?.json()
	
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

func doPostRequest (request: NSMutableURLRequest, callback: (err: NSError?, data: AnyObject?) -> Void, body: [NSObject: AnyObject]) {
	var err: NSError?
	let data = NSJSONSerialization.dataWithJSONObject(body, options: nil, error: &err)
	
	doRequest(request, callback, data)
}

func doRequest (request: NSMutableURLRequest, callback: (err: NSError?, data: AnyObject?) -> Void, body: NSData?) {
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

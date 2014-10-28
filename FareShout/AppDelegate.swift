
import UIKit

var currentUser: User?
let kAPIProtocol = "http://"
let kAPIEndpoint = kAPIProtocol + "localhost:3000"
var sessionCookie: String?

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	var window: UIWindow?

	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		return true
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

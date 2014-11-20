
import UIKit

let iOS8 = floor(NSFoundationVersionNumber) > floor(NSFoundationVersionNumber_iOS_7_1)
var enteredForeground: NSDate! = NSDate()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	var window: UIWindow?

	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		styleApplication()
		
		readSettings()
		checkLoggedIn()
		
		if didRequestForNotifications {
			self.requestForNotifications()
		}
		
		if launchOptions != nil {
			var pushData: [NSObject: AnyObject]? = launchOptions![UIApplicationLaunchOptionsRemoteNotificationKey] as? [NSObject: AnyObject]
			if pushData != nil {
				println(pushData!)
			}
		}
		
		return true
	}
	
	func applicationWillResignActive(application: UIApplication) {
		saveSettings()
	}
	
	func applicationWillTerminate(application: UIApplication) {
		saveSettings()
	}
	
	func styleApplication() {
		UIApplication.sharedApplication().statusBarStyle = .LightContent
		
		if iOS8 {
			UINavigationBar.appearance().translucent = false
		}
		
		UINavigationBar.appearance().barTintColor = UIColor(red: 207/255, green: 0, blue: 20/255, alpha: 0.0)
		UINavigationBar.appearance().tintColor = UIColor.whiteColor()
		
		//var shadow = NSShadow()
		//shadow.shadowColor = UIColor.blackColor()
		//shadow.shadowOffset = CGSizeMake(-1, 0)
		
		var attributes: [NSObject: AnyObject] = [
			NSForegroundColorAttributeName: UIColor.whiteColor(),
			//NSFontAttributeName: UIFont(name: "Avenir Next", size: 18)!
		]
		
		UINavigationBar.appearance().titleTextAttributes = attributes
		UIBarButtonItem.appearance().setTitleTextAttributes(attributes, forState: UIControlState.Normal)
	}
	
	func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
		// if entered foreground in the last second.
		if NSDate().timeIntervalSince1970 - enteredForeground.timeIntervalSince1970 < 1 {
			// Navigate the user to the message screen
			var vc: PageRootViewController = self.window!.rootViewController! as PageRootViewController
			var navController = vc.getCurrentViewController()
			//navController.visibleViewController.navigationController!.popToRootViewControllerAnimated(false)
			if navController.visibleViewController.presentingViewController != nil {
				navController.visibleViewController.navigationController!.dismissViewControllerAnimated(false, completion: nil)
			}
			
			navController.popToRootViewControllerAnimated(false)
			var pageRootDelegate = navController.viewControllers[0] as PageRootDelegate
			pageRootDelegate.openMessageNotification(userInfo["list"] as NSString)
		} else {
			NSNotificationCenter.defaultCenter().postNotificationName("ReceivedMessage", object: self, userInfo: userInfo)
		}
		
		return
	}
	
	func applicationWillEnterForeground(application: UIApplication) {
		enteredForeground = NSDate()
	}
	
	func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
		println(userInfo)
		println(identifier)
		return
	}
	
	func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
		var token = deviceToken.description.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<>"))
		token = token.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
		
		doRequest(makeRequest("/device/" + token, "PUT"), { (err: NSError?, data: AnyObject?) -> Void in
			println("Registered for push notifications. Yaya.")
		}, nil)
		
		println(token)
	}
	
	func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
		println(error)
	}
	
	func requestForNotifications () {
		var app = UIApplication.sharedApplication()
		if iOS8 {
			app.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: UIUserNotificationType.Alert | UIUserNotificationType.Badge | UIUserNotificationType.Sound, categories: nil))
			app.registerForRemoteNotifications()
		} else {
			app.registerForRemoteNotificationTypes(UIRemoteNotificationType.Alert | UIRemoteNotificationType.Badge | UIRemoteNotificationType.Sound)
		}
		
		didRequestForNotifications = true
	}
	
}

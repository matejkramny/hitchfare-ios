
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	var window: UIWindow?

	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		
		styleApplication()
		
		readSettings()
		checkLoggedIn()
		
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
		
		UINavigationBar.appearance().barTintColor = UIColor(red: 180/255, green: 138/255, blue: 179/255, alpha: 1.0)
		UINavigationBar.appearance().tintColor = UIColor.whiteColor()
		
		var shadow = NSShadow()
		shadow.shadowColor = UIColor.blackColor()
		shadow.shadowOffset = CGSizeMake(-1, 0)
		
		var attributes: [NSObject: AnyObject] = [
			NSForegroundColorAttributeName: UIColor.whiteColor(),
			//NSFontAttributeName: UIFont(name: "Avenir Next", size: 18)!
		]
		
		UINavigationBar.appearance().titleTextAttributes = attributes
		UIBarButtonItem.appearance().setTitleTextAttributes(attributes, forState: UIControlState.Normal)
	}
}

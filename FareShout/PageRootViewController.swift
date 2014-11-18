
import UIKit

var mainNavigationDelegate: FareShoutNavigationDelegate!

protocol FareShoutNavigationDelegate {
	func showNavigationBar()
	func hideNavigationBar()
}

@objc protocol PageRootDelegate {
	func pageRootTitle() -> NSString?
	func presentHike()
}

class PageRootViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, FareShoutNavigationDelegate, UIScrollViewDelegate {
	var vcs: [AnyObject] = []
	var pageCtrl: UIPageViewController?

	@IBOutlet weak var navigationBar: UINavigationBar!
	@IBOutlet weak var rightButton: UIBarButtonItem!
	@IBOutlet weak var leftButton: UIBarButtonItem!
	@IBOutlet weak var titleView: UIView!
	
	var titleBarText: UILabel!
	var pageIndicator: UIPageControl!
	var currentViewIndex: Int = 1
	
	var maskLayer: CAGradientLayer!
	var scrollView: UIScrollView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		mainNavigationDelegate = self
		
		var attributes: [NSObject: AnyObject] = [
			NSFontAttributeName: UIFont(name: "FontAwesome", size: 20)!
		]
		self.rightButton.setTitleTextAttributes(attributes, forState: UIControlState.Normal)
		self.leftButton.setTitleTextAttributes(attributes, forState: UIControlState.Normal)
		self.rightButton.title = NSString(format: "%@  %@", NSString.fontAwesomeIconStringForEnum(FAIcon.FASearch), NSString.fontAwesomeIconStringForEnum(FAIcon.FAThumbsOUp))
		self.leftButton.title = NSString.fontAwesomeIconStringForEnum(FAIcon.FACog)
		
		self.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
		self.navigationBar.shadowImage = UIImage()
		self.navigationBar.translucent = true
		// set navigbar.hidden = true to hide
		
		self.titleBarText = UILabel(frame: CGRectMake(0, 0, self.titleView.frame.size.width, self.titleView.frame.size.height - 10))
		self.titleBarText.textAlignment = NSTextAlignment.Center
		self.titleBarText.textColor = UIColor.whiteColor()
		self.titleBarText.font = UIFont.boldSystemFontOfSize(18.0)
		
		self.pageIndicator = UIPageControl(frame: CGRectMake(self.titleView.frame.size.width / 2 - 39 / 2, 10, 39, 37))
		self.pageIndicator.numberOfPages = 3
		self.pageIndicator.currentPage = 1
		
		self.titleView.clipsToBounds = true
		self.titleView.backgroundColor = UIColor.clearColor()
		self.titleView.addSubview(self.titleBarText)
		
		// Shadow mask
		self.maskLayer = CAGradientLayer()
		var outerColor: CGColorRef = UIColor(red: 207/255, green: 0, blue: 20/255, alpha: 1.0).CGColor
		var innerColor: CGColorRef = UIColor(red: 207/255, green: 0, blue: 20/255, alpha: 0.0).CGColor
		self.maskLayer.colors = [outerColor, innerColor, innerColor, outerColor]
		self.maskLayer.locations = [0.0, 0.2, 0.8, 1.0]
		self.maskLayer.bounds = CGRectMake(0, 0, self.titleView.frame.size.width, self.titleView.frame.size.height)
		self.maskLayer.anchorPoint = CGPointZero
		self.maskLayer.startPoint = CGPointMake(0.0, 0.5)
		self.maskLayer.endPoint = CGPointMake(1.0, 0.5)
		
		self.titleView.layer.addSublayer(self.maskLayer)
		self.titleView.addSubview(self.pageIndicator)
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		if pageCtrl == nil && currentUser != nil {
			pageCtrl = UIPageViewController(transitionStyle: UIPageViewControllerTransitionStyle.Scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.Horizontal, options: nil)
			
			pageCtrl!.dataSource = self
			pageCtrl!.delegate = self
			
			pageCtrl!.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
			
			self.addChildViewController(pageCtrl!)
			self.view.addSubview(pageCtrl!.view)
			pageCtrl!.didMoveToParentViewController(self)
			
			var storyboard = UIStoryboard(name: "Main", bundle: nil)
			vcs.append(storyboard.instantiateViewControllerWithIdentifier("myProfile"))
			vcs.append(storyboard.instantiateViewControllerWithIdentifier("recent"))
			vcs.append(storyboard.instantiateViewControllerWithIdentifier("friends"))
			
			self.pageCtrl!.setViewControllers([vcs[1]], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
			
			for view in self.pageCtrl!.view.subviews {
				if let v = view as? UIScrollView {
					var scrollView = view as UIScrollView
					scrollView.delegate = self
					
					self.scrollView = scrollView
				}
			}
			
			setTitleBarText()
		}
		
		self.view.bringSubviewToFront(navigationBar)
	}
	
	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return UIStatusBarStyle.LightContent
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		if currentUser == nil {
			self.performSegueWithIdentifier("showLogin", sender: nil)
			return
		}
	}
	
	func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
		for (i, v) in enumerate(vcs) {
			if v as UIViewController == viewController {
				if i < vcs.count - 1 {
					return vcs[i+1] as? UIViewController
				} else {
					return nil
				}
			}
		}
		
		return nil
	}
	
	func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
		for (i, v) in enumerate(vcs) {
			if v as UIViewController == viewController {
				if i > 0 {
					return vcs[i-1] as? UIViewController
				} else {
					return nil
				}
			}
		}
		
		return nil
	}
	
	func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [AnyObject], transitionCompleted completed: Bool) {
		var viewControllers = self.pageCtrl!.viewControllers
		for (i, v) in enumerate(vcs) {
			if v === viewControllers[0] {
				currentViewIndex = i
				self.pageIndicator.currentPage = currentViewIndex
				break
			}
		}
	}
	
	func showNavigationBar() {
		self.navigationBar.hidden = false
		self.scrollView.scrollEnabled = true
	}
	
	func hideNavigationBar() {
		self.navigationBar.hidden = true
		self.scrollView.scrollEnabled = false
	}
	
	func setTitleBarText () {
		var vc: PageRootDelegate = vcs[currentViewIndex].viewControllers![0] as PageRootDelegate
		self.titleBarText.text = vc.pageRootTitle()
	}
	
	func scrollViewDidScroll(scrollView: UIScrollView) {
		var d = scrollView.contentOffset.x - self.view.frame.width
		var ratio = d / self.view.frame.width
		
		//println(ratio)
		
		// prevent scroll further than bounds
		if ratio <= 0 && currentViewIndex == 0 {
			scrollView.setContentOffset(CGPointMake(self.view.frame.width, scrollView.contentOffset.y), animated: false)
			ratio = 0
		} else if ratio >= 0 && currentViewIndex == 2 {
			scrollView.setContentOffset(CGPointMake(self.view.frame.width, scrollView.contentOffset.y), animated: false)
			ratio = 0
		}
		
		var newX = self.titleView.frame.size.width * ratio * -2
		var width = self.titleView.frame.size.width * 2
		
		var vcIndex = currentViewIndex
		var frame: CGRect = self.titleBarText.frame
		
		if ratio >= 0.5 && currentViewIndex < 2 {
			vcIndex = currentViewIndex + 1
			frame = CGRectMake(newX + width, 0, frame.size.width, frame.size.height)
		} else if ratio <= -0.5 && currentViewIndex > 0 {
			vcIndex = currentViewIndex - 1
			frame = CGRectMake(newX - width, 0, frame.size.width, frame.size.height)
		} else {
			frame = CGRectMake(newX, 0, frame.size.width, frame.size.height)
		}
		
		// Update text frame
		self.titleBarText.frame = frame
		
		// Update title
		var vc: PageRootDelegate = vcs[vcIndex].viewControllers![0] as PageRootDelegate
		self.titleBarText.text = vc.pageRootTitle()
	}
	
	@IBAction func didPressHike(sender: AnyObject) {
		var vc: PageRootDelegate = vcs[currentViewIndex].viewControllers![0] as PageRootDelegate
		vc.presentHike()
	}
	
}

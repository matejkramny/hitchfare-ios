
import UIKit

class PageRootViewController: UIViewController, UIPageViewControllerDataSource {
	var vcs: [AnyObject] = []
	var pageCtrl: UIPageViewController?

	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		if pageCtrl == nil && currentUser != nil {
			pageCtrl = UIPageViewController(transitionStyle: UIPageViewControllerTransitionStyle.Scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.Horizontal, options: nil)
			pageCtrl!.dataSource = self
			pageCtrl!.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
			
			self.addChildViewController(pageCtrl!)
			self.view.addSubview(pageCtrl!.view)
			pageCtrl!.didMoveToParentViewController(self)
			
			var storyboard = UIStoryboard(name: "Main", bundle: nil)
			vcs.append(storyboard.instantiateViewControllerWithIdentifier("myProfile"))
			vcs.append(storyboard.instantiateViewControllerWithIdentifier("recent"))
			vcs.append(storyboard.instantiateViewControllerWithIdentifier("friends"))
			
			self.pageCtrl!.setViewControllers([vcs[0]], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
		}
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
	
}

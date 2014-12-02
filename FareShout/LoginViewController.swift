
import UIKit

class LoginViewController: UIViewController, FacebookCtrlDelegate, UIScrollViewDelegate {
	
	@IBOutlet weak var pageCtrl: UIPageControl!
	@IBOutlet weak var scrollView: UIScrollView!
	
	var images: [UIImageView] = []
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.scrollView.delegate = self
		
		images.append(UIImageView(image: UIImage(named: "login_1")))
		images.append(UIImageView(image: UIImage(named: "login_2")))
		images.append(UIImageView(image: UIImage(named: "login_3")))
		images.append(UIImageView(image: UIImage(named: "login_4")))
		images.append(UIImageView(image: UIImage(named: "login_5")))
		
		self.pageCtrl.currentPage = 0;
		self.pageCtrl.numberOfPages = images.count;
		
		self.pageCtrl.addTarget(self, action: "pageChanged:", forControlEvents: UIControlEvents.ValueChanged)
		
		FacebookCtrl.sharedInstance().delegate = self
		FacebookCtrl.sharedInstance().requestAccessToFacebook()
	}
	
	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return UIStatusBarStyle.LightContent
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		for (i, img) in enumerate(images) {
			img.frame = CGRectMake(self.scrollView.frame.size.width * CGFloat(i), 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)
			
			self.scrollView.addSubview(img)
		}
		
		self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * CGFloat(self.images.count), self.scrollView.contentSize.height)
	}
	
	@IBAction func doLogin(sender: UIButton) {
		if FacebookCtrl.sharedInstance().checkUseEnableFacebook() {
			FacebookCtrl.sharedInstance().getInformationSelf()
		}
	}
	
	func pageChanged(sender: UIPageControl) {
		self.scrollView.setContentOffset(CGPointMake(self.scrollView.frame.size.width * CGFloat(self.pageCtrl.currentPage), self.scrollView.contentOffset.y), animated: true)
	}
	
	func scrollViewDidScroll(scrollView: UIScrollView) {
		var pageWidth = self.scrollView.frame.size.width
		self.pageCtrl.currentPage = (Int)(floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1)
	}
	
	func onFinishedGetInformationSelf(_response: [NSString : AnyObject]!) {
		currentUser = User(_response: _response)
		currentUser?.register({ (error, data) -> Void in
			self.dismissViewControllerAnimated(true, completion: nil)
		})
	}
}

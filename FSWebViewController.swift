
import UIKit

class FSWebViewController: UIViewController, UIWebViewDelegate {
    @IBOutlet weak var _webView: UIWebView!
    var _flag : String!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        var image : UIImage! = UIImage(named: "BackGround")
        var imageView : UIImageView! = UIImageView(image: image)
        imageView.frame = UIScreen.mainScreen().bounds
        self.view.addSubview(imageView)
        
        // Endpoint Setting
        var endpoint : String! = ""
        if _flag == "Privacy" { endpoint = "/privacy" }
        else if _flag == "Terms of Service" { endpoint = "/terms" }
		
		var url = NSURL(string: kAPIEndpoint + endpoint)
        var request = NSMutableURLRequest(URL: url!)
        if sessionCookie != nil {
            request.setValue(sessionCookie, forHTTPHeaderField: "Cookie")
        }
        request.HTTPShouldHandleCookies = true
        request.HTTPMethod = "GET"
		
		_webView.delegate = self
        _webView.loadRequest(request)
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        self.view.exchangeSubviewAtIndex(self.view.subviews.count-1, withSubviewAtIndex: 0)
    }
	
	func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
		println("Error!")
	}
	
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.title = _flag
    }
}

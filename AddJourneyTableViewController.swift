
import UIKit

class AddJourneyTableViewController: UITableViewController {
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "cancel:")
	}
	
	func cancel(sender: AnyObject) {
		self.dismissViewControllerAnimated(true, completion: nil)
	}
}


import UIKit

class CarsTableViewController: UITableViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.navigationItem.title = "Cars"
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addCar:")
	}
	
	func addCar (sender: AnyObject) {
		self.performSegueWithIdentifier("addCar", sender: nil)
	}
	
}

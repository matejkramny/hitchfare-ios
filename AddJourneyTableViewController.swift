
import UIKit

class AddJourneyTableViewController: UITableViewController {
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "cancel:")
		
		self.tableView.registerNib(UINib(nibName: "TextFieldTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "TextField")
		self.tableView.registerNib(UINib(nibName: "SwitchTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "Switch")
	}
	
	func cancel(sender: AnyObject) {
		self.dismissViewControllerAnimated(true, completion: nil)
	}
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 4
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		if indexPath.row < 3 {
			var cell = tableView.dequeueReusableCellWithIdentifier("TextField", forIndexPath: indexPath) as TextFieldTableViewCell
			
			if indexPath.row == 0 {
				cell.label.text = "Title"
			} else if indexPath.row == 1 {
				cell.label.text = "Departure"
			} else if indexPath.row == 2 {
				cell.label.text = "Destination"
			}
			
			return cell as UITableViewCell
		} else if indexPath.row == 3 {
			// I am a driver / Passenger switch
			var cell = tableView.dequeueReusableCellWithIdentifier("Switch", forIndexPath: indexPath) as SwitchTableViewCell
			
			cell.toggle.removeAllSegments()
			cell.toggle.insertSegmentWithTitle("I am a Driver", atIndex: 0, animated: false)
			cell.toggle.insertSegmentWithTitle("Passenger", atIndex: 1, animated: false)
			cell.toggle.setEnabled(true, forSegmentAtIndex: 0)
			
			return cell as UITableViewCell
			// Availability
		/*} else if indexPath.row == 4 {
			// Price
		} else if indexPath.row == 5 {
			// Start & End Date
		*/} else {
			return tableView.dequeueReusableCellWithIdentifier("basic", forIndexPath: indexPath) as UITableViewCell
		}
	}
	
	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 44
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		var cell: TextFieldTableViewCell = tableView.cellForRowAtIndexPath(indexPath) as TextFieldTableViewCell
		cell.field.becomeFirstResponder()
		
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}
}

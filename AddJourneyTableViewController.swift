
import UIKit

class AddJourneyTableViewController: UITableViewController, StartEndTableViewCellProtocol {
	var startEndCellHeight: CGFloat = 88.0
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "cancel:")
		
		self.tableView.registerNib(UINib(nibName: "TextFieldTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "TextField")
		self.tableView.registerNib(UINib(nibName: "SwitchTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "Switch")
		self.tableView.registerNib(UINib(nibName: "StepperTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "Stepper")
		self.tableView.registerNib(UINib(nibName: "PriceTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "Price")
		self.tableView.registerNib(UINib(nibName: "StartEndTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "StartEnd")
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
	}
	
	func cancel(sender: AnyObject) {
		self.dismissViewControllerAnimated(true, completion: nil)
	}
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 7
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
			cell.toggle.selectedSegmentIndex = 0
			
			return cell as UITableViewCell
		} else if indexPath.row == 4 {
			// Availability
			var cell = tableView.dequeueReusableCellWithIdentifier("Stepper", forIndexPath: indexPath) as StepperTableViewCell
			
			cell.label.text = "Availability"
			
			return cell as UITableViewCell
		} else if indexPath.row == 5 {
			// Price
			var cell = tableView.dequeueReusableCellWithIdentifier("Price", forIndexPath: indexPath) as PriceTableViewCell
			
			cell.label.text = "Price"
			cell.initialize()
			
			return cell as UITableViewCell
		} else if indexPath.row == 6 {
			// Start & End Date
			var cell = tableView.dequeueReusableCellWithIdentifier("StartEnd", forIndexPath: indexPath) as StartEndTableViewCell
			
			cell.initialize()
			cell.delegate = self
			
			return cell as UITableViewCell
		} else {
			return tableView.dequeueReusableCellWithIdentifier("basic", forIndexPath: indexPath) as UITableViewCell
		}
	}
	
	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		if indexPath.row == 5 {
			return 88
		}
		if indexPath.row == 6 {
			return startEndCellHeight
		}
		
		return 44
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		var cell: TextFieldTableViewCell = tableView.cellForRowAtIndexPath(indexPath) as TextFieldTableViewCell
		cell.field.becomeFirstResponder()
		
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}
	
	func StartEndTableViewCellAnimateCellHeight(cell: StartEndTableViewCell) {
		if startEndCellHeight == cell.preferredHeight {
			return
		}
		
		startEndCellHeight = cell.preferredHeight
		
		var indexPath: NSIndexPath = NSIndexPath(forRow: 6, inSection: 0)
		self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
		self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
	}
}

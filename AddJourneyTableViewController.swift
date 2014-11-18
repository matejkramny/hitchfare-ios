
import UIKit

class AddJourneyTableViewController: UITableViewController, StartEndTableViewCellProtocol, CarSelectionProtocol, StepperCellDelegate, FSTextFieldCellProtocol, SwitchCellProtocol, PriceCellDelegate {
	
	var startEndCellHeight: CGFloat = 88.0
	var journey: Journey = Journey()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.navigationController?.navigationBar.translucent = false
		
		self.navigationController!.navigationBar.barStyle = UIBarStyle.Black
		
		self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "cancel:")
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: "save:")
		
		self.tableView.registerNib(UINib(nibName: "FSTextFieldTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "TextField")
		self.tableView.registerNib(UINib(nibName: "SwitchTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "Switch")
		self.tableView.registerNib(UINib(nibName: "StepperTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "Stepper")
		self.tableView.registerNib(UINib(nibName: "PriceTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "Price")
		self.tableView.registerNib(UINib(nibName: "StartEndTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "StartEnd")
	}
	
	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return UIStatusBarStyle.LightContent
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
	}
	
	func cancel(sender: AnyObject) {
		self.dismissViewControllerAnimated(true, completion: nil)
	}
	
	func save(sender: AnyObject) {
		SVProgressHUD.showProgress(0, status: "Saving..", maskType: SVProgressHUDMaskType.Black)
		
		journey.update({ (err: NSError?, data: AnyObject?) -> Void in
			if err != nil {
				SVProgressHUD.showErrorWithStatus(err?.domain)
				return
			}
			
			SVProgressHUD.showSuccessWithStatus("Saved.")
			self.navigationController!.dismissViewControllerAnimated(true, completion: nil)
		})
	}
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 6
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0, 1, 3, 5:
			return 1
		case 2, 4:
			return 2
		default:
			return 0
		}
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		if indexPath.section == 0 {
			var cell = tableView.dequeueReusableCellWithIdentifier("TextField", forIndexPath: indexPath) as? FSTextFieldTableViewCell
			if cell == nil {
				cell = FSTextFieldTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "TextField")
			}
			
			cell!.label.text = "Title"
			cell!.field.placeholder = "Name of your Hitch"
			cell!.field.text = journey.name
			cell!.delegate = self
			cell!.initialize()
			
			return cell! as UITableViewCell
		} else if indexPath.section == 1 {
			var cell = tableView.dequeueReusableCellWithIdentifier("carSelector", forIndexPath: indexPath) as? UITableViewCell
			
			cell!.textLabel.text = "Car"
			
			var car_id = ""
			if journey.car != nil {
				car_id = journey.car!
			}
			
			var car = storage.findCarWithId(car_id)
			if car != nil {
				cell!.detailTextLabel!.text = car!.name
			} else {
				cell!.detailTextLabel!.text = ""
			}
			
			return cell!
		} else if indexPath.section == 2 {
			var cell = tableView.dequeueReusableCellWithIdentifier("TextField", forIndexPath: indexPath) as? FSTextFieldTableViewCell
			if cell == nil {
				cell = FSTextFieldTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "TextField")
			}
			
			cell!.delegate = self
			cell!.initialize()
			
			if indexPath.row == 0 {
				cell!.label.text = "Departure"
				cell!.field.placeholder = "Departing from ..."
				cell!.field.text = journey.startLocation
			} else if indexPath.row == 1 {
				cell!.label.text = "Destination"
				cell!.field.placeholder = "Going to ..."
				cell!.field.text = journey.endLocation
			}
			
			return cell!
		} else if indexPath.section == 3 {
			// I am a driver / Passenger switch
			var cell = tableView.dequeueReusableCellWithIdentifier("Switch", forIndexPath: indexPath) as? SwitchTableViewCell
			if cell == nil {
				cell = SwitchTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Switch")
			}
			
			cell!.initialize()
			cell!.delegate = self
			cell!.toggle.removeAllSegments()
			cell!.toggle.insertSegmentWithTitle("I am a Driver", atIndex: 0, animated: false)
			cell!.toggle.insertSegmentWithTitle("Passenger", atIndex: 1, animated: false)
			
			if journey.isDriver {
				cell!.toggle.selectedSegmentIndex = 0
			} else {
				cell!.toggle.selectedSegmentIndex = 1
			}
			
			return cell! as UITableViewCell
		} else if indexPath.section == 4 && indexPath.row == 0 {
			// Availability
			var cell = tableView.dequeueReusableCellWithIdentifier("Stepper", forIndexPath: indexPath) as? StepperTableViewCell
			if cell == nil {
				cell = StepperTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Stepper")
			}
			
			cell!.label.text = "Availability"
			if journey.availableSeats != nil {
				cell!.label.text = cell!.label.text! + ": " + String(journey.availableSeats!)
			}
			
			cell!.initialize()
			cell!.delegate = self
			
			return cell! as UITableViewCell
		} else if indexPath.section == 4 && indexPath.row == 1 {
			// Price
			var cell = tableView.dequeueReusableCellWithIdentifier("Price", forIndexPath: indexPath) as? PriceTableViewCell
			if cell == nil {
				cell = PriceTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Price")
			}
			
			cell!.initialize()
			cell!.delegate = self
			
			cell!.label.text = "Price"
			cell!.slider.value = Float(journey.price)
			cell!.updatePrice()
			
			return cell! as UITableViewCell
		} else if indexPath.section == 5 {
			// Start & End Date
			var cell = tableView.dequeueReusableCellWithIdentifier("StartEnd", forIndexPath: indexPath) as? StartEndTableViewCell
			
			if cell == nil {
				cell = StartEndTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "StartEnd")
			}
			
			cell!.initialize()
			cell!.delegate = self
			cell!.startDateField.text = journey.startDateHuman
			cell!.endDateField.text = journey.endDateHuman
			
			if NSString(string: cell!.startDateField.text).length == 0 {
				cell!.startDateField.text = cell!.getDateFormatter().stringFromDate(NSDate())
			}
			
			if NSString(string: cell!.endDateField.text).length == 0 {
				cell!.endDateField.text = cell!.getDateFormatter().stringFromDate(NSDate())
			}
			
			return cell! as UITableViewCell
		} else {
			return tableView.dequeueReusableCellWithIdentifier("rightDetail", forIndexPath: indexPath) as UITableViewCell
		}
	}
	
	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		if indexPath.section == 4 && indexPath.row == 1 {
			return 88
		}
		if indexPath.section == 5 {
			return startEndCellHeight
		}
		
		return 44
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		switch indexPath.section {
		case 0, 2:
			var cell: FSTextFieldTableViewCell = tableView.cellForRowAtIndexPath(indexPath) as FSTextFieldTableViewCell
			cell.field.becomeFirstResponder()
		case 1:
			self.performSegueWithIdentifier("openCars", sender: nil)
			return
		default:
			break
		}
		
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "openCars" {
			var dc = segue.destinationViewController as CarsTableViewController
			dc.selectCarMode = true
			dc.delegate = self
			
			var car_id = ""
			if journey.car != nil {
				car_id = journey.car!
			}
			
			var car = storage.findCarWithId(car_id)
			if car != nil {
				dc.selectedCar = car!
			}
		}
	}
	
	// StartEnd cell protocol
	
	func StartEndTableViewCellAnimateCellHeight(cell: StartEndTableViewCell) {
		if startEndCellHeight == cell.preferredHeight {
			return
		}
		
		startEndCellHeight = cell.preferredHeight
		
		var indexPath: NSIndexPath = NSIndexPath(forRow: 0, inSection: 5)
		self.tableView.reloadData()
		self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
	}
	
	func StartEndTableViewCellDateChanged(cell: StartEndTableViewCell, startDate: NSDate) {
		journey.startDate = startDate
		journey.startDateHuman = cell.getDateFormatter().stringFromDate(startDate)
	}
	
	func StartEndTableViewCellDateChanged(cell: StartEndTableViewCell, endDate: NSDate) {
		journey.endDate = endDate
		journey.endDateHuman = cell.getDateFormatter().stringFromDate(endDate)
	}
	
	// CarSelectionProtocol
	
	func didSelectCar(car: Car) {
		journey.car = car._id
		
		self.tableView.reloadData()
		self.tableView.selectRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1), animated: false, scrollPosition: UITableViewScrollPosition.None)
	}
	
	// StepperCellDelegate
	
	func StepperValueChanged(cell: StepperTableViewCell, value: Double) {
		// Availability
		journey.availableSeats = Int(value)
		
		let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 4)) as StepperTableViewCell
		cell.label.text = "Availability"
		if journey.availableSeats != nil {
			cell.label.text = cell.label.text! + ": " + String(journey.availableSeats!)
		}
	}
	
	// FSTextFieldCellDelegate
	
	func FSTextFieldCellValueChanged(cell: FSTextFieldTableViewCell, value: NSString?) {
		if cell == self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) {
			journey.name = value
		} else if cell == self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 2)) {
			journey.startLocation = value
		} else if cell == self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 2)) {
			journey.endLocation = value
		}
	}
	
	// SwitchCellProtocol
	
	func SwitchCellValueChanged(cell: SwitchTableViewCell) {
		journey.isDriver = cell.toggle.selectedSegmentIndex == 0
	}
	
	// PriceCellDelegate
	
	func PriceCellValueChanged(cell: PriceTableViewCell) {
		journey.price = cell.slider.value
	}
	
}

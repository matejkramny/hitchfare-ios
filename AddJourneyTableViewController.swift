
import UIKit

class AddJourneyTableViewController: UITableViewController, StartEndTableViewCellProtocol, CarSelectionProtocol, StepperCellDelegate, FSTextFieldCellProtocol, SwitchCellProtocol, PriceCellDelegate {
	
	var startEndCellHeight: CGFloat = 44.0
	var journey: Journey = Journey()
	
	var originalStepperColor: UIColor?
	
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
		
		var image : UIImage! = UIImage(named: "BackGround")
		var imageView : UIImageView! = UIImageView(image: image)
		imageView.frame = UIScreen.mainScreen().bounds
		self.tableView.backgroundView = imageView
		self.tableView.separatorColor = UIColor(red: 145/255.0, green: 101/255.0, blue: 105/255.0, alpha: 1)
	}
	
	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return UIStatusBarStyle.LightContent
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		if !didRequestForNotifications {
			var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
			appDelegate.requestForNotifications()
		}
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
		return 5
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0, 2, 4:
			return 1
		case 1, 3:
			return 2
		default:
			return 0
		}
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		if indexPath.section == 0 {
			var cell = tableView.dequeueReusableCellWithIdentifier("carSelector", forIndexPath: indexPath) as? UITableViewCell
			
			cell!.textLabel!.text = "Car"
			
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
		} else if indexPath.section == 1 {
			var cell = tableView.dequeueReusableCellWithIdentifier("TextField", forIndexPath: indexPath) as? FSTextFieldTableViewCell
			if cell == nil {
				cell = FSTextFieldTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "TextField")
			}
			
			cell!.delegate = self
			cell!.initialize()
			
			cell!.field.keyboardType = UIKeyboardType.Default
			cell!.field.autocapitalizationType = UITextAutocapitalizationType.Words
			cell!.field.autocorrectionType = UITextAutocorrectionType.No
			
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
		} else if indexPath.section == 2 {
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
		} else if indexPath.section == 3 && indexPath.row == 0 {
			// Availability
			var cell = tableView.dequeueReusableCellWithIdentifier("Stepper", forIndexPath: indexPath) as? StepperTableViewCell
			if cell == nil {
				cell = StepperTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Stepper")
			}
			
			cell!.stepper.maximumValue = 6
			cell!.stepper.minimumValue = 0
			
			cell!.label.text = "Availability"
			if journey.availableSeats != nil {
				cell!.label.text = cell!.label.text! + ": " + String(journey.availableSeats!)
				cell!.stepper.value = Double(journey.availableSeats!)
			}
			
			cell!.initialize()
			cell!.delegate = self
			
			return cell! as UITableViewCell
		} else if indexPath.section == 3 && indexPath.row == 1 {
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
		} else if indexPath.section == 4 {
			// Start & End Date
			var cell = tableView.dequeueReusableCellWithIdentifier("StartEnd", forIndexPath: indexPath) as? StartEndTableViewCell
			
			if cell == nil {
				cell = StartEndTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "StartEnd")
			}
			
			cell!.initialize()
			cell!.delegate = self
			cell!.startDateField.text = journey.startDateHuman
			
			if NSString(string: cell!.startDateField.text).length == 0 {
				cell!.startDateField.text = cell!.getDateFormatter().stringFromDate(NSDate())
			}
			
			return cell! as UITableViewCell
		} else {
			return tableView.dequeueReusableCellWithIdentifier("rightDetail", forIndexPath: indexPath) as UITableViewCell
		}
	}
	
	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		if indexPath.section == 3 && indexPath.row == 1 {
			return 88
		}
		if indexPath.section == 4 {
			return startEndCellHeight
		}
		
		return 44
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		switch indexPath.section {
		case 1:
			var cell: FSTextFieldTableViewCell = tableView.cellForRowAtIndexPath(indexPath) as FSTextFieldTableViewCell
			cell.field.becomeFirstResponder()
		case 0:
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
		
		var indexPath: NSIndexPath = NSIndexPath(forRow: 0, inSection: 4)
		self.tableView.reloadData()
		self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
	}
	
	func StartEndTableViewCellDateChanged(cell: StartEndTableViewCell, toDate: NSDate) {
		journey.startDate = toDate
		journey.startDateHuman = cell.getDateFormatter().stringFromDate(toDate)
	}
	
	// CarSelectionProtocol
	
	func didSelectCar(car: Car) {
		journey.car = car._id
		journey.availableSeats = car.seats - 1
		
		var cell: StepperTableViewCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 3)) as StepperTableViewCell
		cell.stepper.value = Double(journey.availableSeats!)
		cell.label.text = "Availability: " + String(journey.availableSeats!)
		
		var carCell: UITableViewCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))!
		carCell.detailTextLabel!.text = car.name
		carCell.setNeedsDisplay()
		self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
	}
	
	// StepperCellDelegate
	
	func StepperValueChanged(cell: StepperTableViewCell, value: Double) {
		// Availability
		journey.availableSeats = Int(value)
		
		let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 3)) as StepperTableViewCell
		cell.label.text = "Availability"
		if journey.availableSeats != nil {
			cell.label.text = cell.label.text! + ": " + String(journey.availableSeats!)
		}
	}
	
	// FSTextFieldCellDelegate
	
	func FSTextFieldCellValueChanged(cell: FSTextFieldTableViewCell, value: NSString?) {
		if cell == self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1)) {
			journey.startLocation = value
		} else if cell == self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 1)) {
			journey.endLocation = value
		}
	}
	
	// SwitchCellProtocol
	
	func SwitchCellValueChanged(cell: SwitchTableViewCell) {
		journey.isDriver = cell.toggle.selectedSegmentIndex == 0
		
		var stepperCell: StepperTableViewCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 3)) as StepperTableViewCell
		
		if journey.isDriver {
			stepperCell.stepper.enabled = true
			if self.originalStepperColor != nil {
				stepperCell.stepper.tintColor = self.originalStepperColor!
			}
		} else {
			stepperCell.stepper.enabled = false
			self.originalStepperColor = stepperCell.stepper.tintColor
			stepperCell.stepper.tintColor = UIColor.grayColor()
		}
	}
	
	// PriceCellDelegate
	
	func PriceCellValueChanged(cell: PriceTableViewCell) {
		journey.price = cell.slider.value
	}
	
}

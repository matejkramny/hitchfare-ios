
import UIKit

protocol FSSearchPropertiesDelegate {
	func FSSearchPropertiesSetAssembledAttributes (properties: Journey?, attributes: NSString?)
}

class FSSearchPropertiesTableViewController: UITableViewController, FSTextFieldCellProtocol, StartEndTableViewCellProtocol, LocationFinderDelegate {
	
	var startEndCellHeight: CGFloat = 44.0
	var properties: Journey = Journey()
	var lookingForDeparture: Bool = false
	
	var delegate: FSSearchPropertiesDelegate?
	
	override func viewDidLoad() {
		self.navigationItem.title = "Search Properties"
		self.navigationItem.setHidesBackButton(true, animated: false)
		self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "applySearchProperties:")
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Default", style: UIBarButtonItemStyle.Plain, target: self, action: "applyDefaultProperties")
		
		self.tableView.registerNib(UINib(nibName: "FSTextFieldTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "TextField")
		self.tableView.registerNib(UINib(nibName: "StartEndTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "StartEnd")
		
		var image : UIImage! = UIImage(named: "BackGround")
		var imageView : UIImageView! = UIImageView(image: image)
		imageView.frame = UIScreen.mainScreen().bounds
		self.tableView.backgroundView = imageView
		self.tableView.separatorColor = UIColor(red: 145/255.0, green: 101/255.0, blue: 105/255.0, alpha: 1)
		self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
	}
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 3
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		if indexPath.section < 2 {
			var cell = tableView.dequeueReusableCellWithIdentifier("TextField", forIndexPath: indexPath) as? FSTextFieldTableViewCell
			if cell == nil {
				cell = FSTextFieldTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "TextField")
			}
			
			cell!.delegate = self
			cell!.initialize()
			
			cell!.field.keyboardType = UIKeyboardType.Default
			cell!.field.autocapitalizationType = UITextAutocapitalizationType.Words
			cell!.field.autocorrectionType = UITextAutocorrectionType.No
			cell!.field.enabled = true
			
			if indexPath.section == 0 {
				cell!.label.text = "Departure"
				cell!.field.placeholder = "Departing from ..."
				cell!.field.text = properties.startLocation
			} else if indexPath.section == 1 {
				cell!.label.text = "Destination"
				cell!.field.placeholder = "Going to ..."
				cell!.field.text = properties.endLocation
			}
			
			return cell!
		}
		
		// Start & End Date
		var cell = tableView.dequeueReusableCellWithIdentifier("StartEnd", forIndexPath: indexPath) as? StartEndTableViewCell
		
		if cell == nil {
			cell = StartEndTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "StartEnd")
		}
		
		cell!.datePickerMode = UIDatePickerMode.Date
		cell!.datePickerDateFormat = "dd/MM/yy"
		cell!.initialize()
		cell!.delegate = self
		
		if properties.startDate != nil {
			let dateFormatter = NSDateFormatter()
			dateFormatter.dateFormat = "dd/MM/yy"
			cell!.startDateField.text = dateFormatter.stringFromDate(properties.startDate!)
		}
		
		if NSString(string: cell!.startDateField.text).length == 0 {
			cell!.startDateField.text = cell!.getDateFormatter().stringFromDate(NSDate())
		}
		
		return cell! as UITableViewCell
	}
	
	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		if indexPath.section == 2 {
			return startEndCellHeight
		}
		
		return 44.0
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		if indexPath.section == 2 {
			return
		}
		
		var cell: FSTextFieldTableViewCell = tableView.cellForRowAtIndexPath(indexPath) as FSTextFieldTableViewCell
		cell.field.becomeFirstResponder()
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "openLocationFinder" {
			var vc = segue.destinationViewController as LocationFinderTableViewController
			
			var isDeparture: Bool = sender as Bool
			self.lookingForDeparture = isDeparture
			
			vc.delegate = self
			
			if isDeparture == true {
				vc.navigationItem.title = "Departure"
				vc.cellTitle = "Departing from ..."
			} else {
				vc.navigationItem.title = "Destination"
				vc.cellTitle = "Going to ..."
			}
		}
	}
	
	func applySearchProperties (sender: AnyObject?) {
		if self.delegate != nil {
			self.delegate!.FSSearchPropertiesSetAssembledAttributes(properties, attributes: properties.searchAttributes())
		}
		
		self.navigationController!.popViewControllerAnimated(true)
	}
	
	func applyDefaultProperties () {
		if self.delegate != nil {
			self.delegate!.FSSearchPropertiesSetAssembledAttributes(nil, attributes: nil)
		}
		
		self.navigationController!.popViewControllerAnimated(true)
	}
	
	//MARK: Delegates etc
	
	func FSTextFieldCellEditingBegan(cell: FSTextFieldTableViewCell?) {
		dispatch_after(0, dispatch_get_main_queue(), {
			cell!.field.resignFirstResponder()
			
			if cell! == self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) {
				self.performSegueWithIdentifier("openLocationFinder", sender: true)
			} else if cell! == self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1)) {
				self.performSegueWithIdentifier("openLocationFinder", sender: false)
			}
			
			return
		})
	}
	
	func FSTextFieldCellValueChanged(cell: FSTextFieldTableViewCell?, value: NSString?) {
		if value == nil || value!.length == 0 {
			if cell == self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) {
				self.properties.startLocation = nil
				self.properties.startLat = nil
				self.properties.startLng = nil
			} else if cell == self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1)) {
				self.properties.endLocation = nil
				self.properties.endLat = nil
				self.properties.endLng = nil
			}
		}
	}
	
	func StartEndTableViewCellAnimateCellHeight(cell: StartEndTableViewCell) {
		if startEndCellHeight == cell.preferredHeight {
			return
		}
		
		startEndCellHeight = cell.preferredHeight
		
		var indexPath: NSIndexPath = NSIndexPath(forRow: 0, inSection: 2)
		self.tableView.reloadData()
		self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
	}
	
	func StartEndTableViewCellDateChanged(cell: StartEndTableViewCell, toDate: NSDate) {
	}
	
	func didSelectLocation(location: LocationResult) {
		var indexPath: NSIndexPath!
		
		if self.lookingForDeparture == true {
			indexPath = NSIndexPath(forRow: 0, inSection: 0)
		} else {
			indexPath = NSIndexPath(forRow: 0, inSection: 1)
		}
		
		var cell = self.tableView.cellForRowAtIndexPath(indexPath) as FSTextFieldTableViewCell
		cell.field.text = location.name
		
		if self.lookingForDeparture == true {
			self.properties.startLocation = location.name
			self.properties.startLat = location.location.latitude
			self.properties.startLng = location.location.longitude
		} else {
			self.properties.endLocation = location.name
			self.properties.endLat = location.location.latitude
			self.properties.endLng = location.location.longitude
		}
	}
	
	func didClearLocation() {
		if self.lookingForDeparture == true {
			self.properties.startLocation = nil
			self.properties.startLat = nil
			self.properties.startLng = nil
		} else {
			self.properties.endLocation = nil
			self.properties.endLat = nil
			self.properties.endLng = nil
		}
		
		self.tableView.reloadData()
	}
	
}


import UIKit

protocol StartEndTableViewCellProtocol {
	func StartEndTableViewCellAnimateCellHeight(cell: StartEndTableViewCell)
	func StartEndTableViewCellDateChanged(cell: StartEndTableViewCell, toDate: NSDate)
}

class StartEndTableViewCell: UITableViewCell, UITextFieldDelegate {

	@IBOutlet weak var startDateField: UITextField!
	
	var preferredHeight: CGFloat = 44.0
	
	var datePicker: UIDatePicker?
	var showsDatePicker: Bool = false
	var datePickerMode: UIDatePickerMode = UIDatePickerMode.DateAndTime
	var datePickerDateFormat: NSString = "dd/MM/yy hh:mm a"
	
	var delegate: StartEndTableViewCellProtocol?
	
	func initialize() {
		startDateField.delegate = self
		startDateField.placeholder = "Meeting Time"
	}
	
	func getDateFormatter() -> NSDateFormatter {
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = self.datePickerDateFormat
		
		return dateFormatter
	}
	
	func showDatePicker () {
		showsDatePicker = true
		preferredHeight = 260.0
		
		if datePicker == nil {
			datePicker = UIDatePicker(frame: CGRectMake(0, startDateField.frame.origin.y + startDateField.frame.size.height, self.frame.width, 216.0))
			datePicker!.datePickerMode = self.datePickerMode
			datePicker!.minimumDate = NSDate()
			datePicker!.addTarget(self, action: "datePickerValueChanged:", forControlEvents: UIControlEvents.ValueChanged)
			datePicker!.tintColor = UIColor.whiteColor()
		}
		
		var dateString: NSString = startDateField.text
		
		if dateString.length > 0 {
			var dateFormatter = getDateFormatter()
			
			var date = dateFormatter.dateFromString(dateString)
			
			if date != nil {
				datePicker!.date = date!
			}
		} else {
			datePicker!.date = NSDate()
		}
		
		self.addSubview(datePicker!)
		self.setNeedsDisplay()
	}
	
	func hideDatePicker () {
		showsDatePicker = false
		preferredHeight = 44.0
		
		datePicker?.removeFromSuperview()
	}
	
	func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
		if showsDatePicker {
			self.hideDatePicker()
		} else {
			self.showDatePicker()
		}
		
		delegate!.StartEndTableViewCellAnimateCellHeight(self)
		
		return false
	}
	
	func datePickerValueChanged (sender: AnyObject?) {
		var dateFormatter = self.getDateFormatter()
		
		// Needs some formatting
		startDateField.text = dateFormatter.stringFromDate(datePicker!.date)
		self.delegate!.StartEndTableViewCellDateChanged(self, toDate: datePicker!.date)
	}
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
	}
	
	required init(coder aDecoder: NSCoder) {
		var _preferredHeight = aDecoder.decodeDoubleForKey("preferredHeight")
		if _preferredHeight != 0 {
			preferredHeight = CGFloat(_preferredHeight)
		}
		
		datePicker = aDecoder.decodeObjectOfClass(UIDatePicker.self, forKey: "datePicker") as? UIDatePicker
		showsDatePicker = aDecoder.decodeBoolForKey("showsDatePicker")
		
		super.init(coder: aDecoder)
	}
	
	override func encodeWithCoder(aCoder: NSCoder) {
		aCoder.encodeDouble(Double(preferredHeight), forKey: "preferredHeight")
		aCoder.encodeObject(datePicker, forKey: "datePicker")
		aCoder.encodeBool(showsDatePicker, forKey: "showsDatePicker")
		
		super.encodeWithCoder(aCoder)
	}
	
}

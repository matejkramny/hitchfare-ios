
import UIKit

enum StartEndTableViewCellField: Int {
	case None = 0
	case Start = 1
	case End = 2
}

protocol StartEndTableViewCellProtocol {
	func StartEndTableViewCellAnimateCellHeight(cell: StartEndTableViewCell)
	func StartEndTableViewCellDateChanged(cell: StartEndTableViewCell, startDate: NSDate)
	func StartEndTableViewCellDateChanged(cell: StartEndTableViewCell, endDate: NSDate)
}

class StartEndTableViewCell: UITableViewCell, UITextFieldDelegate {

	@IBOutlet weak var startDateField: UITextField!
	@IBOutlet weak var endDateField: UITextField!
	
	var preferredHeight: CGFloat = 88.0
	
	var datePicker: UIDatePicker?
	var showsDatePicker: Bool = false
	var currentDatePicker: StartEndTableViewCellField = StartEndTableViewCellField.None
	
	var delegate: StartEndTableViewCellProtocol?
	
	func initialize() {
		startDateField.delegate = self
		endDateField.delegate = self
		
		startDateField.placeholder = "Start Date"
		endDateField.placeholder = "End Date"
	}
	
	func getDateFormatter() -> NSDateFormatter {
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "dd/MM/yyyy"
		
		return dateFormatter
	}
	
	func showDatePicker (field: StartEndTableViewCellField) {
		showsDatePicker = true
		preferredHeight = 304.0
		
		if datePicker == nil {
			datePicker = UIDatePicker(frame: CGRectMake(0, startDateField.frame.origin.y + startDateField.frame.size.height, self.frame.width, 216.0))
			datePicker!.datePickerMode = UIDatePickerMode.Date
			datePicker!.addTarget(self, action: "datePickerValueChanged:", forControlEvents: UIControlEvents.ValueChanged)
		}
		
		var dateString: NSString = ""
		if field == StartEndTableViewCellField.Start {
			dateString = startDateField.text
		} else if field == StartEndTableViewCellField.End {
			dateString = endDateField.text
		}
		
		if dateString.length > 0 {
			var dateFormatter = getDateFormatter()
			
			var date = dateFormatter.dateFromString(dateString)
			
			if date != nil {
				datePicker!.date = date!
			}
		} else {
			datePicker!.date = NSDate()
		}
		
		currentDatePicker = field
		self.addSubview(datePicker!)
		self.setNeedsDisplay()
	}
	
	func hideDatePicker () {
		showsDatePicker = false
		preferredHeight = 88.0
		
		datePicker?.removeFromSuperview()
		currentDatePicker = StartEndTableViewCellField.None
	}
	
	func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
		if textField == startDateField {
			if showsDatePicker && currentDatePicker == StartEndTableViewCellField.Start {
				self.hideDatePicker()
			} else {
				self.showDatePicker(StartEndTableViewCellField.Start)
			}
		} else if textField == endDateField {
			if showsDatePicker && currentDatePicker == StartEndTableViewCellField.End {
				self.hideDatePicker()
			} else {
				self.showDatePicker(StartEndTableViewCellField.End)
			}
		}
		
		delegate!.StartEndTableViewCellAnimateCellHeight(self)
		
		return false
	}
	
	func datePickerValueChanged (sender: AnyObject?) {
		var dateFormatter = self.getDateFormatter()
		
		if currentDatePicker == StartEndTableViewCellField.Start {
			// Needs some formatting
			startDateField.text = dateFormatter.stringFromDate(datePicker!.date)
			self.delegate!.StartEndTableViewCellDateChanged(self, startDate: datePicker!.date)
		} else if currentDatePicker == StartEndTableViewCellField.End {
			endDateField.text = dateFormatter.stringFromDate(datePicker!.date)
			self.delegate!.StartEndTableViewCellDateChanged(self, endDate: datePicker!.date)
		}
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
		currentDatePicker = StartEndTableViewCellField(rawValue: aDecoder.decodeIntegerForKey("currentDatePicker"))!
		
		super.init(coder: aDecoder)
	}
	
	override func encodeWithCoder(aCoder: NSCoder) {
		aCoder.encodeDouble(Double(preferredHeight), forKey: "preferredHeight")
		aCoder.encodeObject(datePicker, forKey: "datePicker")
		aCoder.encodeBool(showsDatePicker, forKey: "showsDatePicker")
		aCoder.encodeInteger(currentDatePicker.rawValue, forKey: "currentDatePicker")
		
		super.encodeWithCoder(aCoder)
	}
	
}

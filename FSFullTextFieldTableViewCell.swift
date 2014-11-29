
import UIKit

class FSFullTextFieldTableViewCell: UITableViewCell {
	
	@IBOutlet weak var field: UITextField!
	var delegate: FSTextFieldCellProtocol?
	
	func initialize () {
		self.field.addTarget(self, action: "valueChanged:", forControlEvents: UIControlEvents.EditingChanged)
	}
	
	func valueChanged(sender: AnyObject?) {
		if delegate == nil {
			return
		}
		
		self.delegate!.FSTextFieldCellValueChanged(nil, value: self.field.text)
	}
	
}

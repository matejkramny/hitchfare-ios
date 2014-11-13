
import UIKit

protocol FSTextFieldCellProtocol {
	func FSTextFieldCellValueChanged(cell: FSTextFieldTableViewCell, value: NSString?)
}

class FSTextFieldTableViewCell: UITableViewCell {
	@IBOutlet weak var label: UILabel!
	@IBOutlet weak var field: UITextField!
	
	var delegate: FSTextFieldCellProtocol?
	
	func initialize () {
		self.field.addTarget(self, action: "valueChanged:", forControlEvents: UIControlEvents.EditingChanged)
	}
	
	func valueChanged(sender: AnyObject?) {
		if delegate == nil {
			return
		}
		
		self.delegate!.FSTextFieldCellValueChanged(self, value: self.field.text)
	}
}

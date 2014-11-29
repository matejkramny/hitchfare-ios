
import UIKit

protocol FSTextFieldCellProtocol {
	func FSTextFieldCellValueChanged(cell: FSTextFieldTableViewCell?, value: NSString?)
	func FSTextFieldCellEditingBegan(cell: FSTextFieldTableViewCell?)
}

class FSTextFieldTableViewCell: UITableViewCell {
	@IBOutlet weak var label: UILabel!
	@IBOutlet weak var field: UITextField!
	
	var delegate: FSTextFieldCellProtocol?
	
	func initialize () {
		self.field.addTarget(self, action: "valueChanged:", forControlEvents: UIControlEvents.EditingChanged)
		self.field.addTarget(self, action: "editingBegan:", forControlEvents: UIControlEvents.EditingDidBegin)
	}
	
	func valueChanged(sender: AnyObject?) {
		if delegate == nil {
			return
		}
		
		self.delegate!.FSTextFieldCellValueChanged(self, value: self.field.text)
	}
	
	func editingBegan(sender: AnyObject?) {
		if delegate == nil {
			return
		}
		
		self.delegate!.FSTextFieldCellEditingBegan(self)
	}
}

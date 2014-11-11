
import UIKit

protocol TextFieldTableViewCellDelegate {
	func openCars(sender: UIButton)
}

class TextFieldTableViewCell: UITableViewCell {
	var delegate: TextFieldTableViewCellDelegate!
	
	@IBOutlet weak var label: UILabel!
	@IBOutlet weak var field: UITextField!
	
	func openCars(sender: UIButton) {
		self.delegate.openCars(sender)
	}
	
	func style () {
		self.selectionStyle = UITableViewCellSelectionStyle.None
	}
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		self.style()
	}
	
	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		self.style()
	}
}



import UIKit

protocol TextFieldTableViewCellDelegate {
	func openCars(sender: UIButton)
}

class TextFieldTableViewCell: UITableViewCell {
	var delegate: TextFieldTableViewCellDelegate!
	
	@IBOutlet weak var label: UILabel!
	@IBOutlet weak var field: UITextField!
	
	@IBAction func openCars(sender: UIButton) {
		self.delegate.openCars(sender)
	}
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
	}
	
	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
}


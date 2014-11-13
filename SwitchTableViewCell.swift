
import UIKit

protocol SwitchCellProtocol {
	func SwitchCellValueChanged(cell: SwitchTableViewCell)
}

class SwitchTableViewCell: UITableViewCell {
	
	@IBOutlet weak var toggle: UISegmentedControl!
	
	var delegate: SwitchCellProtocol?
	
	func initialize() {
		toggle.addTarget(self, action: "valueChanged:", forControlEvents: UIControlEvents.ValueChanged)
	}
	
	func valueChanged(sender: AnyObject?) {
		if self.delegate != nil {
			self.delegate!.SwitchCellValueChanged(self)
		}
	}
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
	}
	
	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
}

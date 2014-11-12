
import UIKit

class SwitchTableViewCell: UITableViewCell {
	
	@IBOutlet weak var toggle: UISegmentedControl!
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
	}
	
	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
}

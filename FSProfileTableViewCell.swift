
import UIKit

protocol FSProfileTableViewCellDelegate {
	func openCars(sender: UIButton)
}

class FSProfileTableViewCell: UITableViewCell {
	var delegate: FSProfileTableViewCellDelegate!
	
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var descriptionLabel: UILabel!
	@IBOutlet weak var profileImageView: UIImageView!
	@IBOutlet weak var carButton: UIButton!
	@IBOutlet weak var ratingLabel: UILabel!
	
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


import UIKit

protocol ProfileTableViewCellDelegate {
	func openCars(sender: UIButton)
}

class ProfileTableViewCell: UITableViewCell {
	var delegate: ProfileTableViewCellDelegate!
	
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var descriptionLabel: UILabel!
	@IBOutlet weak var ratingImageView: UIImageView!
	@IBOutlet weak var profileImageView: UIImageView!
	
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

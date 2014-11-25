
import UIKit

protocol JourneyRequestDelegate {
	func JourneyRequestDidPressDelete(cell: JourneyRequestTableViewCell)
}

class JourneyRequestTableViewCell: UITableViewCell {
	
	@IBOutlet weak var profileImageView: UIImageView!
	
	@IBOutlet weak var journeyName: UILabel!
	@IBOutlet weak var requestedLabel: UILabel!
	@IBOutlet weak var deleteButton: UIButton!
	
	var delegate: JourneyRequestDelegate?
	
	@IBAction func didPressDelete(sender: AnyObject) {
		if delegate != nil {
			self.delegate!.JourneyRequestDidPressDelete(self)
		}
	}
	
}

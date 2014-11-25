
import UIKit

protocol AcceptJourneyRequestDelegate {
	func AcceptJourneyRequestDidPressReject(cell: AcceptJourneyRequestTableViewCell)
	func AcceptJourneyRequestDidPressAccept(cell: AcceptJourneyRequestTableViewCell)
}

class AcceptJourneyRequestTableViewCell: UITableViewCell {
	
	@IBOutlet weak var profileImageView: UIImageView!
	
	@IBOutlet weak var journeyName: UILabel!
	@IBOutlet weak var requestedLabel: UILabel!
	@IBOutlet weak var rejectButton: UIButton!
	@IBOutlet weak var acceptButton: UIButton!
	
	var delegate: AcceptJourneyRequestDelegate?
	
	@IBAction func didPressAccept(sender: AnyObject) {
		if delegate != nil {
			self.delegate!.AcceptJourneyRequestDidPressAccept(self)
		}
	}
	
	@IBAction func didPressReject(sender: AnyObject) {
		if delegate != nil {
			self.delegate!.AcceptJourneyRequestDidPressReject(self)
		}
	}
	
}


import UIKit

protocol JourneyReviewDelegate {
	func JourneyReviewDidReview(journey: JourneyPassenger, rating: Int)
}

class ReviewViewController: UIViewController {
	
	@IBOutlet weak var journeyName: UILabel!
	@IBOutlet weak var departureLabel: UILabel!
	@IBOutlet weak var destinationButton: UILabel!
	
	@IBOutlet weak var star1Btn: UILabel!
	@IBOutlet weak var star2Btn: UILabel!
	@IBOutlet weak var star3btn: UILabel!
	@IBOutlet weak var star4btn: UILabel!
	@IBOutlet weak var star5btn: UILabel!
	
	var tapGestureRecognizers: [UITapGestureRecognizer] = []
	
	var journey: JourneyPassenger!
	var delegate: JourneyReviewDelegate?
	
	func setup(delegate: JourneyReviewDelegate, journey: JourneyPassenger) {
		self.delegate = delegate
		self.journey = journey
		
		var btns: [UILabel] = [star1Btn, star2Btn, star3btn, star4btn, star5btn]
		for btn in btns {
			btn.enabled = false
			
			btn.font = UIFont(name: "FontAwesome", size: 26)
			btn.text = NSString.fontAwesomeIconStringForEnum(FAIcon.FAStar)
			var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "didTap:")
			tapGestureRecognizers.append(tapGestureRecognizer)
			btn.addGestureRecognizer(tapGestureRecognizer)
			btn.userInteractionEnabled = true
			
			btn.enabled = true
		}
	}
	
	func didTap (gestureRecognizer: UITapGestureRecognizer) {
		var rating = 0
		
		for (i, gs) in enumerate(tapGestureRecognizers) {
			if gs === gestureRecognizer {
				rating = i + 1
				break
			}
		}
		
		self.delegate!.JourneyReviewDidReview(self.journey, rating: rating)
	}
	
}

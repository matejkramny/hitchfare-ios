
import UIKit
import QuartzCore

class JourneyTableViewCell: UITableViewCell {
	
	@IBOutlet weak var journeyNameLabel: UILabel!
	@IBOutlet weak var destinationLabel: UILabel!
	@IBOutlet weak var departureLabel: UILabel!
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var priceLabel: UILabel!
	@IBOutlet weak var availabilityLabel: UILabel!
	
	func style () {
		self.availabilityLabel.layer.cornerRadius = 13.5
		self.availabilityLabel.layer.masksToBounds = true
	}
	
	func populate(journey: Journey) {
		self.journeyNameLabel.text = journey.name
		self.departureLabel.text = "Departure: " + journey.startLocation!
		self.destinationLabel.text = "Destination: " + journey.endLocation!
		var date = journey.startDateHuman
		if date != nil {
			self.dateLabel.text = "Date: " + date!
		} else {
			self.dateLabel.text = "Date: N/A"
		}
		self.priceLabel.text = NSString(format: "£%.2f", journey.price)
		self.availabilityLabel.text = NSString(format: "%d", journey.availableSeats!)
	}
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
	}
	
	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
}

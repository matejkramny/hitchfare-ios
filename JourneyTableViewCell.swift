
import UIKit
import QuartzCore

class JourneyTableViewCell: MGSwipeTableCell {
	
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
		
		var startLocation = journey.startLocation
		if startLocation != nil {
			self.departureLabel.text = "Departure: " + startLocation!
		} else {
			self.departureLabel.text = "Departure: N/A"
		}
		
		var endLocation = journey.endLocation
		if endLocation != nil {
			self.destinationLabel.text = "Destination: " + endLocation!
		} else {
			self.destinationLabel.text = "Destination: N/A"
		}
        
		var date = journey.startDate
		if date != nil {
            var dateFormatter = NSDateFormatter()
            var timeZone = NSTimeZone.localTimeZone()                       // Local TimeZone
            dateFormatter.timeZone = timeZone
            dateFormatter.dateFormat = "dd/MM/YYYY"
            var changedDate = dateFormatter.stringFromDate(date!)
            
			self.dateLabel.text = "Date: " + changedDate
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


import UIKit
import QuartzCore

let driverColor : UIColor! = UIColor(red: 228/255.0, green: 30/255.0, blue: 38/255.0, alpha: 1)

class JourneyTableViewCell: MGSwipeTableCell {
	
	@IBOutlet weak var journeyNameLabel: UILabel!
	@IBOutlet weak var destinationLabel: UILabel!
	@IBOutlet weak var departureLabel: UILabel!
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var priceLabel: UILabel!
	@IBOutlet weak var availabilityLabel: UILabel!
	@IBOutlet weak var driverImageView: UIImageView!
	@IBOutlet weak var bgView: UIView!
	@IBOutlet weak var availabilityTextLabel: UILabel!
    
	func style () {
		self.availabilityLabel.layer.cornerRadius = 13.5
		self.availabilityLabel.layer.masksToBounds = true
	}
	
	func populate(journey: Journey) {
		self.journeyNameLabel.text = journey.ownerObj!.name
//		if journey.owner! == currentUser!._id! {
//			self.journeyNameLabel.textColor = driverColor
//			self.driverImageView.image = UIImage(named: "DriverTag")
//		} else {
//			self.journeyNameLabel.textColor = UIColor(red: 96/255.0, green: 99/255.0, blue: 102/255.0, alpha: 1)
//			self.driverImageView.image = UIImage(named: "PassengerTag")
//		}
		
		// Not 'journey.isDriver' -- which is correct. The below is expected behaviour by user.. and makes sense :/.
		if journey.isDriver == true {
			self.journeyNameLabel.textColor = driverColor
			self.driverImageView.image = UIImage(named: "DriverTag")
		} else {
			self.journeyNameLabel.textColor = UIColor(red: 96/255.0, green: 99/255.0, blue: 102/255.0, alpha: 1)
			self.driverImageView.image = UIImage(named: "PassengerTag")
		}
		
		self.bgView.backgroundColor = driverColor.colorWithAlphaComponent(0.1)
		
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
            dateFormatter.dateFormat = "dd/MM/YY hh:mm"
            var changedDate = dateFormatter.stringFromDate(date!)
            
			self.dateLabel.text = "Date: " + changedDate
		} else {
			self.dateLabel.text = "Date: N/A"
		}
		self.priceLabel.text = NSString(format: "£%.2f", floor(journey.price))
		self.availabilityLabel.text = NSString(format: "%d", journey.availableSeats!)
		
		if journey.isDriver == false {
			self.availabilityLabel.hidden = true
			self.availabilityTextLabel.hidden = true
			self.priceLabel.hidden = true
		} else {
			self.availabilityLabel.hidden = false
			self.availabilityTextLabel.hidden = false
			self.priceLabel.hidden = false
		}
	}
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
	}
	
	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
}

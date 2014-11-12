
import UIKit

class PriceTableViewCell: UITableViewCell {
	
	@IBOutlet weak var label: UILabel!
	@IBOutlet weak var symbolLabel: UILabel!
	@IBOutlet weak var field: UITextField!
	@IBOutlet weak var slider: UISlider!
	
	func initialize() {
		self.slider.addTarget(self, action: "sliderChangedValue:", forControlEvents: UIControlEvents.ValueChanged)
		
		self.slider.maximumValue = 100.0
		self.slider.minimumValue = 0.0
		self.slider.value = 10.0
		self.field.text = "£10.00"
	}
	
	func sliderChangedValue (sender: AnyObject?) {
		self.field.text = NSString(format: "£%.2f", self.slider.value)
	}
	
	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
}

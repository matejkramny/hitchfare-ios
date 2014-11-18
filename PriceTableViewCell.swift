
import UIKit

protocol PriceCellDelegate {
	func PriceCellValueChanged(cell: PriceTableViewCell)
}

class PriceTableViewCell: UITableViewCell {
	
	@IBOutlet weak var label: UILabel!
	@IBOutlet weak var field: UITextField!
	@IBOutlet weak var slider: UISlider!
	
	var delegate: PriceCellDelegate?
	
	func initialize() {
		self.slider.addTarget(self, action: "sliderChangedValue:", forControlEvents: UIControlEvents.ValueChanged)
		
		self.slider.maximumValue = 100.0
		self.slider.minimumValue = 0.0
		self.slider.value = 10.0
		self.field.text = "£10"
	}
	
	func sliderChangedValue (sender: AnyObject?) {
		self.updatePrice()
		
		if self.delegate != nil {
			self.delegate!.PriceCellValueChanged(self)
		}
	}
	
	func updatePrice () {
		self.field.text = NSString(format: "£%d", Int(self.slider.value))
	}
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
	}
	
	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
}

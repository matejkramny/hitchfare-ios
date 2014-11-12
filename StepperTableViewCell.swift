
import UIKit

protocol StepperCellDelegate {
	func StepperValueChanged(cell: StepperTableViewCell, value: Double)
}

class StepperTableViewCell: UITableViewCell {
	
	@IBOutlet weak var stepper: UIStepper!
	@IBOutlet weak var label: UILabel!
	
	var delegate: StepperCellDelegate? = nil
	
	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	func initialize() {
		stepper.addTarget(self, action: "valueChanged:", forControlEvents: UIControlEvents.ValueChanged)
	}
	
	func valueChanged(sender: AnyObject?) {
		if self.delegate != nil {
			self.delegate!.StepperValueChanged(self, value: self.stepper.value)
		}
	}
	
}

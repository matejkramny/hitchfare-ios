
import UIKit

class CarViewController: UIViewController {
	
	var car: Car!
	
	@IBOutlet weak var carImageView: UIImageView!
	
	@IBOutlet weak var carNameLabel: UILabel!
	@IBOutlet weak var carDescriptionLabel: UILabel!
	@IBOutlet weak var editBtn: UIButton!
	
	@IBAction func editBtnPressed(sender: AnyObject) {
		println("HellO")
	}
	
	func setup (selectedCarMode: Bool) {
		if self.car.picture != nil {
			self.carImageView.sd_setImageWithURL(NSURL(string: car.picture!))
			self.carImageView.contentMode = UIViewContentMode.ScaleAspectFit
		}
		
		self.carNameLabel.text = car.name
		self.carDescriptionLabel.text = car.carDescription
		
		self.view.backgroundColor = UIColor.clearColor()
		
		self.editBtn.addTarget(self, action: "editBtnPressed:", forControlEvents: UIControlEvents.TouchUpInside)
		
		if selectedCarMode == true {
			self.editBtn.setNeedsDisplay()
			self.editBtn.setTitle("Select", forState: UIControlState.Normal)
		}
	}
	
}

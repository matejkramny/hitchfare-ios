
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
	
}


import UIKit

protocol CarSelectionProtocol {
	func didSelectCar (car: Car)
}

class CarsTableViewController: UIViewController {
	
	@IBOutlet weak var scrollView: UIScrollView!
	
	var selectCarMode: Bool = false
	var selectedCar: Car? = nil
	var delegate: CarSelectionProtocol? = nil
	
	var carViews: [CarViewController] = []
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.navigationItem.title = "Cars"
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addCar:")
	}
	
	func addCar (sender: AnyObject) {
		self.performSegueWithIdentifier("addCar", sender: nil)
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		self.refreshCars(nil)
	}
	
	func refreshCars (sender: AnyObject?) {
		storage.getCars({ (err: NSError?) -> Void in
			self.createCarVCs()
		})
	}
	
	func createCarVCs () {
		for vc in self.carViews {
			vc.view.removeFromSuperview()
		}
		
		for (i, car) in enumerate(storage.cars) {
			
			var view: CarViewController = UINib(nibName: "CarViewController", bundle: NSBundle.mainBundle()).instantiateWithOwner(nil, options: nil)[0] as CarViewController
			
			view.carImageView.sd_setImageWithURL(NSURL(string: "http://www.autotrader.co.uk/articleresources/wp-content/uploads/2014/03/AudiTT_380.jpg"))
			view.carNameLabel.text = car.name
			view.carDescriptionLabel.text = car.carDescription
			
			view.view.frame = CGRectMake(view.view.frame.size.width * CGFloat(i), view.view.frame.origin.y, view.view.frame.size.width, view.view.frame.size.height)
			
			self.scrollView.addSubview(view.view)
			
		}
		
		self.scrollView.contentSize = CGSizeMake(self.view.frame.width * CGFloat(storage.cars.count), self.scrollView.contentSize.height)
		
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		if selectCarMode == true {
			self.selectedCar = storage.cars[indexPath.row]
			
			if self.delegate != nil {
				self.delegate!.didSelectCar(selectedCar!)
			}
			
			self.navigationController!.popViewControllerAnimated(true)
		}
	}
	
}

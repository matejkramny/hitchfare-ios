
import UIKit

protocol CarSelectionProtocol {
	func didSelectCar (car: Car)
}

class CarsTableViewController: UIViewController {
	
	@IBOutlet weak var scrollView: UIScrollView!
	
	var selectCarMode: Bool = false
	var selectedCar: Car? = nil
	var delegate: CarSelectionProtocol? = nil
	var user: User?
	var cars: [Car] = []
	
	var carViews: [CarViewController] = []
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if self.selectCarMode == true {
			self.navigationItem.title = "Select Car"
		} else {
			self.navigationItem.title = "Cars"
		}
		
		if self.user != nil && self.user!._id != currentUser!._id {
			self.navigationItem.title = "Cars"
		} else {
			self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addCar:")	
		}
		
		UIGraphicsBeginImageContext(self.view.frame.size)
		UIImage(named: "BackGround")!.drawInRect(self.view.bounds)
		var image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		self.view.backgroundColor = UIColor(patternImage: image)
	}
	
	func addCar (sender: AnyObject) {
		self.performSegueWithIdentifier("addCar", sender: nil)
	}
	
	func editCar (sender: Car) {
		self.performSegueWithIdentifier("addCar", sender: sender)
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		self.refreshCars(nil)
	}
	
	func refreshCars (sender: AnyObject?) {
		if self.user == nil {
			storage.getCars(currentUser!, callback: { (err: NSError?) -> Void in
				self.cars = storage.cars
				self.createCarVCs()
			})
		} else {
			Car.getAll(self.user!, callback: { (err: NSError?, data: [Car]) -> Void in
				self.cars = data
				self.createCarVCs()
			})
		}
	}
	
	func createCarVCs () {
		for vc in self.carViews {
			vc.view.removeFromSuperview()
		}
		self.carViews = []
		
		for (i, car) in enumerate(self.cars) {
			
			var view: CarViewController = UINib(nibName: "CarViewController", bundle: NSBundle.mainBundle()).instantiateWithOwner(nil, options: nil)[0] as! CarViewController
			view.car = car
			view.setup(self.selectCarMode)
			
			view.view.frame = CGRectMake(view.view.frame.size.width * CGFloat(i), view.view.frame.origin.y, view.view.frame.size.width, view.view.frame.size.height)
			
			if self.user != nil && self.user!._id != currentUser!._id {
				view.editBtn.hidden = true
			}
			view.editBtn.addTarget(self, action: "editBtnPressed:", forControlEvents: UIControlEvents.TouchUpInside)
			
			self.scrollView.addSubview(view.view)
			self.carViews.append(view)
		}
		
		self.scrollView.contentSize = CGSizeMake(self.view.frame.width * CGFloat(self.cars.count), self.scrollView.contentSize.height)
		
	}
	
	func editBtnPressed (sender: UIButton) {
		var car: Car?
		for (i, view) in enumerate(carViews) {
			if view.editBtn === sender {
				car = view.car
				break
			}
		}
		
		if car == nil {
			return
		}
		
		if selectCarMode == true {
			self.selectedCar = car!
			
			if self.delegate != nil {
				self.delegate!.didSelectCar(selectedCar!)
			}
			
			self.navigationController!.popViewControllerAnimated(true)
		} else {
			self.editCar(car!)
		}
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "addCar" && sender != nil && sender as? Car != nil {
			var vc: AddCarTableViewController = segue.destinationViewController as! AddCarTableViewController
			vc.car = sender as! Car
		}
	}
	
}

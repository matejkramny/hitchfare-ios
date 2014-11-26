
import UIKit

protocol CarSelectionProtocol {
	func didSelectCar (car: Car)
}

class CarsTableViewController: UITableViewController {
	
	var selectCarMode: Bool = false
	var selectedCar: Car? = nil
	var delegate: CarSelectionProtocol? = nil
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.navigationItem.title = "Cars"
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addCar:")
		
		self.refreshControl = UIRefreshControl()
		self.refreshControl!.addTarget(self, action: "refreshCars:", forControlEvents: UIControlEvents.ValueChanged)
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
			self.refreshControl!.endRefreshing()
			self.tableView.reloadData()
		})
	}
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return storage.cars.count
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("rightDetail", forIndexPath: indexPath) as UITableViewCell
		
		var car = storage.cars[indexPath.row]
		cell.textLabel.text = car.name
		cell.detailTextLabel!.text = String(car.seats) + " Seat"
		if car.seats > 1 {
			cell.detailTextLabel!.text = cell.detailTextLabel!.text! + "s"
		}
		
		if selectCarMode == true {
			cell.accessoryType = UITableViewCellAccessoryType.None
			
			if car == selectedCar {
				cell.accessoryType = UITableViewCellAccessoryType.Checkmark
			}
		}
		
		return cell
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		if selectCarMode == true {
			self.selectedCar = storage.cars[indexPath.row]
			
			if self.delegate != nil {
				self.delegate!.didSelectCar(selectedCar!)
			}
			
			self.navigationController!.popViewControllerAnimated(true)
		}
	}
	
}

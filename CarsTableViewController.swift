
import UIKit

class CarsTableViewController: UITableViewController {
	
	var cars: [Car] = []
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.navigationItem.title = "Cars"
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addCar:")
		
		self.refreshControl = UIRefreshControl()
		self.refreshControl?.addTarget(self, action: "refreshCars:", forControlEvents: UIControlEvents.ValueChanged)
		
		self.refreshCars(nil)
	}
	
	func addCar (sender: AnyObject) {
		self.performSegueWithIdentifier("addCar", sender: nil)
	}
	
	func refreshCars (sender: AnyObject?) {
		Car.getAll({ (err: NSError?, data: [Car]) -> Void in
			self.cars = data
			
			self.refreshControl?.endRefreshing()
			self.tableView.reloadData()
			
			return
		})
	}
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return cars.count
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("rightDetail", forIndexPath: indexPath) as UITableViewCell
		
		var car = cars[indexPath.row]
		cell.textLabel.text = car.name
		
		return cell
	}
	
}

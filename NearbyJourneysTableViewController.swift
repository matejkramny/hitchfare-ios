
import UIKit

class NearbyJourneysTableViewCell: UITableViewController {
	var journeys: [Journey] = []
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addHike:")
		self.refreshData()
	}
	
	func addHike (sender: AnyObject) {
		self.performSegueWithIdentifier("addJourney", sender: nil)
	}
	
	func refreshData () {
		Journey.getAll({ (err: NSError?, data: [Journey]) -> Void in
			self.journeys = data
			self.tableView.reloadData()
		})
	}
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return journeys.count
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		var cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("rightDetail", forIndexPath: indexPath) as UITableViewCell
		
		cell.textLabel.text = journeys[indexPath.row].name
		
		return cell
	}
}

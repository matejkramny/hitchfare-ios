
import UIKit

class NearbyJourneysTableViewCell: UITableViewController {
	var journeys: [Journey] = []
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.refreshData()
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

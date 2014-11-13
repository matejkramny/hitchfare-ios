
import UIKit

class HikesTableViewCell: UITableViewController {
	
	var journeys: [Journey] = []
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSString.fontAwesomeIconStringForEnum(FAIcon.FAThumbsOUp), style: UIBarButtonItemStyle.Plain, target: self, action: "addHike:")
		
		var attributes: [NSObject: AnyObject] = [
			NSFontAttributeName: UIFont(name: "FontAwesome", size: 20)!
		]
		self.navigationItem.rightBarButtonItem?.setTitleTextAttributes(attributes, forState: UIControlState.Normal)
		
		self.refreshControl = UIRefreshControl()
		self.refreshControl!.addTarget(self, action: "refreshData:", forControlEvents: UIControlEvents.ValueChanged)
		
		self.refreshData(nil)
	}
	
	func addHike (sender: AnyObject) {
		self.performSegueWithIdentifier("addJourney", sender: nil)
	}
	
	func refreshData (sender: AnyObject?) {
		self.refreshControl!.endRefreshing()
	}
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 0
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 0
	}
		
}

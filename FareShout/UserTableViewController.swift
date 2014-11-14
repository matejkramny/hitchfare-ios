
import UIKit

class UserTableViewController: UITableViewController, ProfileTableViewCellDelegate {
	
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
		
		self.tableView.registerNib(UINib(nibName: "JourneyTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "Journey")
		
		self.refreshData(nil)
	}
	
	func addHike (sender: AnyObject) {
		self.performSegueWithIdentifier("addJourney", sender: nil)
	}
	
	func refreshData (sender: AnyObject?) {
		Journey.getMyJourneys({ (err: NSError?, data: [Journey]) -> Void in
			self.journeys = data
			self.refreshControl!.endRefreshing()
			self.tableView.reloadData()
		})
	}
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 2
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0:
			return 1
		case 1:
			return journeys.count
		default:
			return 0
		}
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		if indexPath.section == 0 {
			var cell = tableView.dequeueReusableCellWithIdentifier(cellIDForIndexPath(indexPath), forIndexPath: indexPath) as? UITableViewCell
			
			if cell == nil {
				cell = ProfileTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellIDForIndexPath(indexPath))
			}
			
			if indexPath.section == 0 {
				var c = cell as ProfileTableViewCell
				c.delegate = self
				c.nameLabel.text = currentUser!.name
			}
			
			return cell!
		} else if indexPath.section == 1 {
			var journey = journeys[indexPath.row]
			
			var cell = tableView.dequeueReusableCellWithIdentifier("Journey", forIndexPath: indexPath) as? JourneyTableViewCell
			if cell == nil {
				cell = JourneyTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Journey")
			}
			
			cell!.style()
			cell!.populate(journey)
			
			return cell!
		}
		
		return (tableView.dequeueReusableCellWithIdentifier("rightDetail", forIndexPath: indexPath) as? UITableViewCell)!
	}
	
	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if section == 1 {
			return "Current Journeys"
		}
		
		return nil
	}
	
	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		if indexPath.section == 0 {
			return 120.0
		} else {
			return 126.0
		}
	}
	
	func cellIDForIndexPath(indexPath: NSIndexPath) -> NSString {
		switch indexPath.section {
		case 0:
			return "profileCell"
		default:
			return ""
		}
	}
	
	func openCars(sender: UIButton) {
		self.performSegueWithIdentifier("openCars", sender: nil)
	}
}

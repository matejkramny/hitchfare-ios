
import UIKit

class UserTableViewController: UITableViewController, ProfileTableViewCellDelegate {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addHike:")
	}
	
	func addHike (sender: AnyObject) {
		self.performSegueWithIdentifier("addJourney", sender: nil)
	}
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
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
	}
	
	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 120.0
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

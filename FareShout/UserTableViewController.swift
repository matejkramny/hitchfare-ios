
import UIKit

class UserTableViewController: UITableViewController, FSProfileTableViewCellDelegate, PageRootDelegate {
	
	var journeys: [Journey] = []
	var didAppear: Bool = false
	var isInSegue: Bool = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.navigationController?.navigationBar.translucent = false
		
		self.refreshControl = UIRefreshControl()
		self.refreshControl!.addTarget(self, action: "refreshData:", forControlEvents: UIControlEvents.ValueChanged)
		
		self.tableView.registerNib(UINib(nibName: "JourneyTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "Journey")
		self.tableView.registerNib(UINib(nibName: "FSProfileTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "profileCell")
		
		self.refreshData(nil)
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		mainNavigationDelegate.showNavigationBar()
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		self.isInSegue = false
		self.didAppear = true
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		
		if self.didAppear == false && self.isInSegue == true {
			// Disappearing before appeared.
			mainNavigationDelegate.hideNavigationBar()
		}
	}
	
	override func viewDidDisappear(animated: Bool) {
		super.viewDidDisappear(animated)
		
		self.didAppear = false
	}
	
	func presentHike () {
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
				cell = FSProfileTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellIDForIndexPath(indexPath))
			}
			
			var c = cell as FSProfileTableViewCell
			
			var url = NSURL(string: currentUser!.picture!.url)
			c.profileImageView.sd_setImageWithURL(url!)
			c.profileImageView.layer.cornerRadius = 45
			c.profileImageView.layer.masksToBounds = true
			c.delegate = self
			c.nameLabel.text = currentUser!.name
			
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
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}
	
	func openCars(sender: UIButton) {
		self.performSegueWithIdentifier("openCars", sender: nil)
	}
	
	func pageRootTitle() -> NSString? {
		return "Hitch"
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		self.isInSegue = true
		mainNavigationDelegate.hideNavigationBar()
	}
	
	func openMessageNotification(listId: NSString) {
		MessageList.getList(listId, callback: { (err: NSError?, data: MessageList?) -> Void in
			if data == nil {
				return
			}
			
			self.performSegueWithIdentifier("openMessages", sender: data!)
		})
	}
	
}

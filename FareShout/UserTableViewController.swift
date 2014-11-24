
import UIKit

class UserTableViewController: UITableViewController, FSProfileTableViewCellDelegate, PageRootDelegate, MGSwipeTableCellDelegate {
	
	var journeys: [Journey] = []
	var pendingRequests: [JourneyPassenger] = []
	var didAppear: Bool = false
	var isInSegue: Bool = false
	
	// set to true before loading to indicate the view isn't loaded from UIPage thing
	var presentedFromElsewhere = false
	var shownUser: User!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.navigationController!.navigationBar.translucent = false
		
		self.refreshControl = UIRefreshControl()
		self.refreshControl!.addTarget(self, action: "refreshData:", forControlEvents: UIControlEvents.ValueChanged)
		
		self.tableView.registerNib(UINib(nibName: "JourneyTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "Journey")
		self.tableView.registerNib(UINib(nibName: "FSProfileTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "profileCell")
		
		if shownUser == nil {
			shownUser = currentUser!
		}
		
		if presentedFromElsewhere == true {
			self.navigationItem.title = shownUser.name
		}
		
		self.refreshData(nil)
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		if presentedFromElsewhere == false {
			mainNavigationDelegate.showNavigationBar()
		}
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		self.isInSegue = false
		self.didAppear = true
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		
		if self.didAppear == false && self.isInSegue == true && presentedFromElsewhere == false {
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
		var callback: (err: NSError?, data: [Journey]) -> Void = { (err: NSError?, data: [Journey]) -> Void in
			self.journeys = data
			
			self.refreshControl!.endRefreshing()
			self.tableView.reloadData()
		}
		
		if presentedFromElsewhere {
			Journey.getUserJourneys(shownUser, callback: callback)
		} else {
			JourneyPassenger.getMyJourneyRequests({ (err: NSError?, data: [JourneyPassenger]) -> Void in
				self.pendingRequests = data
				self.tableView.reloadData()
			})
			
			Journey.getMyJourneys(callback)
		}
	}
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 3
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0:
			return 1
		case 2:
			return journeys.count
		case 1:
			return pendingRequests.count
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
			
			if presentedFromElsewhere {
				c.carButton.hidden = true
			}
			
			var url = NSURL(string: shownUser.picture!.url)
			c.profileImageView.sd_setImageWithURL(url!)
			c.profileImageView.layer.cornerRadius = 45
			c.profileImageView.layer.masksToBounds = true
			c.profileImageView.layer.shouldRasterize = true
			c.delegate = self
			c.nameLabel.text = shownUser.name
			c.selectionStyle = UITableViewCellSelectionStyle.None
			
			return cell!
		} else if indexPath.section == 1 {
			var req = pendingRequests[indexPath.row]
			
			var cell = tableView.dequeueReusableCellWithIdentifier("basic", forIndexPath: indexPath) as? UITableViewCell
			if cell == nil {
				//				cell = JourneyTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Journey")
			}
			
			cell!.textLabel!.text = req.journey.name
			
			return cell!
		} else if indexPath.section == 2 {
			var journey = journeys[indexPath.row]
			
			var cell = tableView.dequeueReusableCellWithIdentifier("Journey", forIndexPath: indexPath) as? JourneyTableViewCell
			if cell == nil {
				cell = JourneyTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Journey")
			}
			
			if presentedFromElsewhere == false {
				var deleteBtn = MGSwipeButton(title: NSString.fontAwesomeIconStringForEnum(FAIcon.FATrashO), backgroundColor: UIColor.redColor())
				var editBtn = MGSwipeButton(title: NSString.fontAwesomeIconStringForEnum(FAIcon.FAPencilSquareO), backgroundColor: UIColor.blueColor())
				var passengerBtn = MGSwipeButton(title: "Passengers", backgroundColor: UIColor.blackColor())
				
				deleteBtn.titleLabel!.font = UIFont(name: "FontAwesome", size: 24)!
				editBtn.titleLabel!.font = UIFont(name: "FontAwesome", size: 24)!
				
				cell!.leftButtons = [deleteBtn, editBtn, passengerBtn]
				cell!.leftSwipeSettings.transition = MGSwipeTransition.Transition3D
				cell!.delegate = self
			}
			
			cell!.style()
			cell!.populate(journey)
			
			return cell!
		}
		
		return (tableView.dequeueReusableCellWithIdentifier("rightDetail", forIndexPath: indexPath) as? UITableViewCell)!
	}
	
	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if section == 2 {
			return "Current Journeys"
		}
		if section == 1 {
			return "Pending Requests"
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
		if presentedFromElsewhere && indexPath.section == 2 {
			var journey = journeys[indexPath.row]
			
			SVProgressHUD.showProgress(1.0, status: "Requesting to Join", maskType: SVProgressHUDMaskType.Black)
			
			journey.requestJoin({ (err: NSError?) -> Void in
				SVProgressHUD.dismiss()
			})
		}
		
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
	
	func swipeTableCell(cell: MGSwipeTableCell!, canSwipe direction: MGSwipeDirection) -> Bool {
		return direction == MGSwipeDirection.LeftToRight
	}
	
	func swipeTableCell(cell: MGSwipeTableCell!, tappedButtonAtIndex index: Int, direction: MGSwipeDirection, fromExpansion: Bool) -> Bool {
		var cell: JourneyTableViewCell = cell as JourneyTableViewCell
		UIAlertView(title: "Delete Journey", message: cell.journeyNameLabel.text!, delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "Okay").show()
		
		return true
	}
	
}

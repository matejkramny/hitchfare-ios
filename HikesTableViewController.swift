
import UIKit

class HikesTableViewCell: UITableViewController, PageRootDelegate {
	
	var messages: [MessageList] = []
	var didAppear: Bool = false
	var isInSegue: Bool = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.navigationController?.navigationBar.translucent = false
		
		self.refreshControl = UIRefreshControl()
		self.refreshControl!.addTarget(self, action: "refreshData:", forControlEvents: UIControlEvents.ValueChanged)
		
		self.tableView.registerNib(UINib(nibName: "HikeTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "Hike")
		
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
		MessageList.getLists({ (err: NSError?, data: [MessageList]) -> Void in
			self.refreshControl!.endRefreshing()
			self.messages = data
			self.tableView.reloadData()
		})
	}
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return messages.count
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		var cell = tableView.dequeueReusableCellWithIdentifier("Hike", forIndexPath: indexPath) as? HikeTableViewCell
		
		if cell == nil {
			cell = HikeTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Hike")
		}
		
		var message = messages[indexPath.row]
		
		var user = message.receiver
		if user._id == currentUser!._id! {
			user = message.sender
		}
		
		cell!.nameLabel.text = user.name
		if user.picture != nil {
			cell!.pictureImageView.sd_setImageWithURL(NSURL(string: user.picture!.url))
			cell!.pictureImageView.clipsToBounds = true
			cell!.pictureImageView.layer.cornerRadius = 72/2
		}
		
		if message.lastMessage != nil {
			cell!.messageLabel.text = message.lastMessage!.message
		} else {
			cell!.messageLabel.text = ""
		}
		
		var deleteBtn = MGSwipeButton(title: " " + NSString.fontAwesomeIconStringForEnum(FAIcon.FATrashO) + " ", backgroundColor: UIColor.blackColor())
		var infoBtn = MGSwipeButton(title: NSString.fontAwesomeIconStringForEnum(FAIcon.FAInfo), backgroundColor: UIColor.blackColor())
		var reportBtn = MGSwipeButton(title: NSString.fontAwesomeIconStringForEnum(FAIcon.FAExclamationTriangle), backgroundColor: UIColor.blackColor())
		
		deleteBtn.titleLabel!.font = UIFont(name: "FontAwesome", size: 24)!
		infoBtn.titleLabel!.font = UIFont(name: "FontAwesome", size: 24)!
		reportBtn.titleLabel!.font = UIFont(name: "FontAwesome", size: 24)!
		
		cell!.rightButtons = [deleteBtn, infoBtn, reportBtn]
		cell!.rightSwipeSettings.transition = MGSwipeTransition.TransitionDrag
		
		cell!.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
		
		return cell!
	}
	
	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 88
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		var user = messages[indexPath.row].receiver
		if user._id == currentUser!._id! {
			user = messages[indexPath.row].sender
		}
		
		SVProgressHUD.showProgress(0, status: "Loading Message..", maskType: SVProgressHUDMaskType.Black)
		findMessageList(user._id!, { (list: MessageList?) -> Void in
			self.performSegueWithIdentifier("openMessages", sender: list)
		})
	}
	
	func pageRootTitle() -> NSString? {
		return "Hike"
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		SVProgressHUD.dismiss()
		
		mainNavigationDelegate.hideNavigationBar()
		isInSegue = true
		
		if segue.identifier == "openMessages" {
			var vc: MessagesViewController = segue.destinationViewController as MessagesViewController
			vc.list = sender as MessageList
		}
	}
	
	func openMessageNotification(listId: NSString) {
		SVProgressHUD.showProgress(0, status: "Loading Message..", maskType: SVProgressHUDMaskType.Black)
		
		MessageList.getList(listId, callback: { (err: NSError?, data: MessageList?) -> Void in
			if data == nil {
				return
			}
			
			self.performSegueWithIdentifier("openMessages", sender: data!)
		})
	}
	
	func openJourneyNotification(reload: Bool, info: [NSString : AnyObject]) {
		
	}
		
}

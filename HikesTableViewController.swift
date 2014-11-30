
import UIKit

class HikesTableViewCell: UITableViewController, PageRootDelegate, MGSwipeTableCellDelegate {
	
	var messages: [MessageList] = []
	var didAppear: Bool = false
	var isInSegue: Bool = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.navigationController?.navigationBar.translucent = false
		
		self.refreshControl = UIRefreshControl()
		self.refreshControl!.addTarget(self, action: "refreshData:", forControlEvents: UIControlEvents.ValueChanged)
		self.refreshControl!.tintColor = UIColor.whiteColor()
		
		self.tableView.registerNib(UINib(nibName: "HikeTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "Hike")
        
        var image : UIImage! = UIImage(named: "BackGround")
        var imageView : UIImageView! = UIImageView(image: image)
        imageView.frame = UIScreen.mainScreen().bounds
        self.tableView.backgroundView = imageView
        self.tableView.separatorColor = UIColor(red: 145/255.0, green: 101/255.0, blue: 105/255.0, alpha: 1)
		
		// makes uirefreshcontrol visible..
		self.tableView.backgroundView!.layer.zPosition -= 1
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		mainNavigationDelegate.showNavigationBar()
		
		self.refreshData(nil)
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if self.tableView.respondsToSelector(Selector("setSeparatorInset:")) {
            self.tableView.separatorInset = UIEdgeInsetsZero
        }
        
        if self.tableView.respondsToSelector(Selector("setLayoutMargins:")) {
            self.tableView.layoutMargins = UIEdgeInsetsZero
        }
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
		
		deleteBtn.titleLabel!.font = UIFont(name: "FontAwesome", size: 24)!
		
		cell!.rightButtons = [deleteBtn]
		cell!.rightSwipeSettings.transition = MGSwipeTransition.TransitionDrag
		cell!.delegate = self
		
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
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if cell.respondsToSelector(Selector("setSeparatorInset:")) {
            cell.separatorInset = UIEdgeInsetsZero
        }
        if cell.respondsToSelector(Selector("setLayoutMargins:")) {
            cell.layoutMargins = UIEdgeInsetsZero
        }
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
	
	func swipeTableCell(cell: MGSwipeTableCell!, canSwipe direction: MGSwipeDirection) -> Bool {
		return direction == MGSwipeDirection.RightToLeft
	}
	
	func swipeTableCell(cell: MGSwipeTableCell!, tappedButtonAtIndex index: Int, direction: MGSwipeDirection, fromExpansion: Bool) -> Bool {
		var indexPath: NSIndexPath = self.tableView.indexPathForCell(cell as UITableViewCell)!
		
		SVProgressHUD.showProgress(1.0, status: "Deleting...", maskType: SVProgressHUDMaskType.Black)
		messages[indexPath.row].deleteList({ (err: NSError?) -> Void in
			if err != nil {
				return SVProgressHUD.showErrorWithStatus("Could not delete message")
			}
			
			self.refreshData(nil)
			SVProgressHUD.dismiss()
		})
		
		return true
	}
	
}

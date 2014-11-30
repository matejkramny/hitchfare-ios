
import UIKit

class PassengersTableViewController: UITableViewController {
	var journey: Journey!
	var passengers: [JourneyPassenger] = []
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.refreshControl = UIRefreshControl()
		self.refreshControl!.addTarget(self, action: "refreshData:", forControlEvents: UIControlEvents.ValueChanged)
		self.refreshControl!.tintColor = UIColor.whiteColor()
		
		self.tableView.registerNib(UINib(nibName: "HikeTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "Hike")
		
		self.navigationItem.title = "Passengers"
        
        var image : UIImage! = UIImage(named: "BackGround")
        var imageView : UIImageView! = UIImageView(image: image)
        imageView.frame = UIScreen.mainScreen().bounds
        self.tableView.backgroundView = imageView
        self.tableView.separatorColor = UIColor(red: 145/255.0, green: 101/255.0, blue: 105/255.0, alpha: 1)
		
		if journey.owner! != currentUser!._id! {
			self.navigationItem.title = "Other Passengers"
		}
		
		// makes uirefreshcontrol visible..
		self.tableView.backgroundView!.layer.zPosition -= 1
		
		self.refreshData(nil)
	}
	
	func refreshData (sender: AnyObject?) {
		self.journey.getPassengers({ (err: NSError?, data: [JourneyPassenger]) -> Void in
			self.passengers = []
			
			for d in data {
				if d.user._id! == currentUser!._id! {
					continue
				}
				
				self.passengers.append(d)
			}
			
			self.refreshControl!.endRefreshing()
			self.tableView.reloadData()
		})
	}
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.passengers.count + 1
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		var cell = tableView.dequeueReusableCellWithIdentifier("Hike", forIndexPath: indexPath) as? HikeTableViewCell
		
		if cell == nil {
			cell = HikeTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Hike")
		}
		
		if indexPath.row == 0 {
			cell!.nameLabel.text = self.journey.ownerObj!.name
			if self.journey.ownerObj!.picture != nil {
				cell!.pictureImageView.sd_setImageWithURL(NSURL(string: self.journey.ownerObj!.picture!.url))
				cell!.pictureImageView.clipsToBounds = true
				cell!.pictureImageView.layer.cornerRadius = 72/2
			}
			
			cell!.messageLabel.text = "Driver"
			
			return cell!
		}
		
		var passenger = self.passengers[indexPath.row - 1]
		var user = passenger.user
		
		cell!.nameLabel.text = user.name
		if user.picture != nil {
			cell!.pictureImageView.sd_setImageWithURL(NSURL(string: user.picture!.url))
			cell!.pictureImageView.clipsToBounds = true
			cell!.pictureImageView.layer.cornerRadius = 72/2
		}
		
		cell!.messageLabel.text = "Not Rated."
		if passenger.rated == true {
			cell!.messageLabel.text = "Rating: " + String(passenger.rating) + "/5"
		}
		
		var deleteBtn = MGSwipeButton(title: " " + NSString.fontAwesomeIconStringForEnum(FAIcon.FATrashO) + " ", backgroundColor: UIColor.blackColor())
		var infoBtn = MGSwipeButton(title: NSString.fontAwesomeIconStringForEnum(FAIcon.FAInfo), backgroundColor: UIColor.blackColor())
		var reportBtn = MGSwipeButton(title: NSString.fontAwesomeIconStringForEnum(FAIcon.FAExclamationTriangle), backgroundColor: UIColor.blackColor())
		
		deleteBtn.titleLabel!.font = UIFont(name: "FontAwesome", size: 24)!
		
		cell!.rightButtons = [deleteBtn]
		cell!.rightSwipeSettings.transition = MGSwipeTransition.TransitionDrag
		
		cell!.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
		
		return cell!
	}
	
	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 88
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		var userId: String!
		
		if indexPath.row == 0 {
			if journey.owner! == currentUser!._id! {
				tableView.deselectRowAtIndexPath(indexPath, animated: true)
				return
			}
			
			userId = journey.owner!
		} else {
			var passenger = self.passengers[indexPath.row - 1]
			userId = passenger.user._id!
		}
		
		findMessageList(userId, { (list: MessageList?) -> Void in
			self.performSegueWithIdentifier("openMessage", sender: list)
		})
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		SVProgressHUD.dismiss()
		
		if segue.identifier == "openMessage" {
			var vc: MessagesViewController = segue.destinationViewController as MessagesViewController
			vc.list = sender as MessageList
		}
	}
	
}

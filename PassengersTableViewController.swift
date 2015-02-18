
import UIKit

class PassengersTableViewController: UITableViewController, MGSwipeTableCellDelegate {
	var journey: Journey!
	var passengers: [JourneyPassenger] = []
	
	var avgRating: Double?
	
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
		
		self.journey.averageRating({ (err: NSError?, rating: Double?) -> Void in
			self.avgRating = rating
			self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
		})
	}
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 2
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 0 {
			if self.avgRating != nil && self.journey.carObj != nil {
				return 2
			}
			return self.avgRating != nil ? 2 : 1
		}
		
		return self.passengers.count + 1
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		if indexPath.section == 0 {
			if indexPath.row == 1 || indexPath.row == 0 && self.journey.carObj == nil {
				var cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("rating", forIndexPath: indexPath) as UITableViewCell
				
				cell.textLabel!.font = UIFont(awesomeFontOfSize: 18.0)
				var stars = ""
				
				for var i = 0; i < Int(ceil(self.avgRating!)); i++ {
					var starEnum = FAIcon.FAStar
					
					if i == Int(round(self.avgRating!)) {
						starEnum = FAIcon.FAStarHalf
					}
					
					stars = stars + NSString.fontAwesomeIconStringForEnum(starEnum)
				}
				
				cell.textLabel!.text = NSString(format: "Average Rating: %@", stars)
				cell.textLabel!.textColor = UIColor.whiteColor()
				cell.backgroundColor = UIColor.clearColor()
				
				return cell
			}
			
			var cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("car", forIndexPath: indexPath) as UITableViewCell
			
			cell.textLabel!.text = "Driver's Car"
			cell.detailTextLabel!.text = self.journey.carObj!.name
			cell.textLabel!.textColor = UIColor.whiteColor()
			cell.backgroundColor = UIColor.clearColor()
			
			return cell
		}
		
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
			cell!.messageLabel!.font = UIFont(awesomeFontOfSize: 14.0)
			var stars = ""
			
			for var i = 0; i < passenger.rating; i++ {
				stars = stars + NSString.fontAwesomeIconStringForEnum(FAIcon.FAStar)
			}
			
			cell!.messageLabel!.text = NSString(format: "Rating: %@", stars)
		}
		
		var deleteBtn = MGSwipeButton(title: " " + NSString.fontAwesomeIconStringForEnum(FAIcon.FATrashO) + " ", backgroundColor: UIColor.blackColor())
		var infoBtn = MGSwipeButton(title: NSString.fontAwesomeIconStringForEnum(FAIcon.FAInfo), backgroundColor: UIColor.blackColor())
		var reportBtn = MGSwipeButton(title: NSString.fontAwesomeIconStringForEnum(FAIcon.FAExclamationTriangle), backgroundColor: UIColor.blackColor())
		
		deleteBtn.titleLabel!.font = UIFont(name: "FontAwesome", size: 24)!
		
		cell!.rightButtons = [deleteBtn]
		cell!.delegate = self
		cell!.rightSwipeSettings.transition = MGSwipeTransition.TransitionDrag
		
		cell!.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
		
		return cell!
	}
	
	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		if indexPath.section == 0 {
			return 33
		}
		
		return 88
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		if indexPath.section == 0 {
			if indexPath.row == 1 || indexPath.row == 0 && self.journey.carObj == nil {
				return
			}
			
			// Show off the car..
			let vc: CarViewController = UINib(nibName: "CarViewController", bundle: NSBundle.mainBundle()).instantiateWithOwner(nil, options: nil)[0] as CarViewController
			vc.car = self.journey.carObj!
			vc.navigationItem.title = vc.car.name
			vc.setup(false)
			
			UIGraphicsBeginImageContext(vc.view.frame.size)
			UIImage(named: "BackGround")!.drawInRect(self.view.bounds)
			var image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
			UIGraphicsEndImageContext()
			
			vc.view.backgroundColor = UIColor(patternImage: image)
			vc.editBtn.enabled = false
			vc.editBtn.layer.opacity = 0
			
			self.navigationController!.pushViewController(vc, animated: true)
			return
		}
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
	
	func swipeTableCell(cell: MGSwipeTableCell!, canSwipe direction: MGSwipeDirection) -> Bool {
		return direction == MGSwipeDirection.RightToLeft
	}
	
	func swipeTableCell(cell: MGSwipeTableCell!, tappedButtonAtIndex index: Int, direction: MGSwipeDirection, fromExpansion: Bool) -> Bool {
		var indexPath: NSIndexPath = self.tableView.indexPathForCell(cell as UITableViewCell)!
		
		var passenger = passengers[indexPath.row-1]
		SVProgressHUD.showProgress(1.0, status: "Deleting Passenger", maskType: SVProgressHUDMaskType.Black)
		passenger.rejectRequest({ (err: NSError?) -> Void in
			if err != nil {
				return SVProgressHUD.showErrorWithStatus("Network Error.")
			}
			
			SVProgressHUD.dismiss()
			self.refreshData(nil)
		})
		
		return true
	}
	
}

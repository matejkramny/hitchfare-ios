
import UIKit

class UserTableViewController: UITableViewController, FSProfileTableViewCellDelegate, PageRootDelegate, MGSwipeTableCellDelegate, JourneyRequestDelegate, AcceptJourneyRequestDelegate, PickJourneyDelegate {
    
    // Section title color constant variables.
    let kDefaultSectionTitleColor : UIColor! = UIColor(red: 103/255.0, green: 0/255.0, blue: 10/255.0, alpha: 1)
    let kPastSectionTitleColor : UIColor! = UIColor.grayColor()
	
	var journeys: [Journey] = []
	var pastJourneys: [Journey] = []
	var myPendingRequests: [JourneyPassenger] = []
	var pendingRequests: [JourneyPassenger] = []
	var mutualFriends: [User] = []
	var mutualFriendGestureRecognizers: [UITapGestureRecognizer] = []
	
	var didAppear: Bool = false
	var isInSegue: Bool = false
	
	// set to true before loading to indicate the view isn't loaded from UIPage thing
	var presentedFromElsewhere = false
	var shownUser: User!
	var driverRating: Double? = nil
	
	var profileTapGestureRecognizer: UITapGestureRecognizer!
	let requestedJourneyDateFormatter: NSDateFormatter = NSDateFormatter()
	
	var blackBackdropView: UIView?
	var profileImageView: UIImageView?
	
	// set when the user wants to join a journey which is in passenger mode
	var pickingSelfJourneyForJourney: Journey?
	var pickedJourney: Journey?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.profileTapGestureRecognizer = UITapGestureRecognizer(target: self, action: "openProfileImage")
		self.requestedJourneyDateFormatter.dateFormat = "dd/MM/yyyy"
		
		self.navigationController!.navigationBar.translucent = false
		
		self.refreshControl = UIRefreshControl()
		self.refreshControl!.addTarget(self, action: "refreshData:", forControlEvents: UIControlEvents.ValueChanged)
		self.refreshControl!.tintColor = UIColor.whiteColor()
		
		self.tableView.registerNib(UINib(nibName: "JourneyTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "Journey")
		self.tableView.registerNib(UINib(nibName: "FSProfileTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "profileCell")
		self.tableView.registerNib(UINib(nibName: "JourneyRequestTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "journeyRequest")
		self.tableView.registerNib(UINib(nibName: "AcceptJourneyRequestTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "acceptJourneyRequest")
		self.tableView.registerNib(UINib(nibName: "HikeTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "Hike")
		self.tableView.registerNib(UINib(nibName: "MutualFriendsTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "MutualFriendCell")
		
		var image : UIImage! = UIImage(named: "BackGround")
		var imageView : UIImageView! = UIImageView(image: image)
		imageView.frame = UIScreen.mainScreen().bounds
		self.tableView.backgroundView = imageView
		
		self.tableView.separatorColor = UIColor(red: 145/255.0, green: 101/255.0, blue: 105/255.0, alpha: 1)
		// makes uirefreshcontrol visible..
		self.tableView.backgroundView!.layer.zPosition -= 1
		
		if shownUser == nil {
			shownUser = currentUser!
		}
		
		if presentedFromElsewhere == true {
			self.navigationItem.title = shownUser.name
		}
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		if presentedFromElsewhere == false {
			mainNavigationDelegate.showNavigationBar()
		}
		
		if (self.pickingSelfJourneyForJourney != nil) {
			if self.pickedJourney != nil {
				self.pickingSelfJourneyForJourney!.requestJoinPassenger(self.pickedJourney!, { (err: NSError?) -> Void in
					if err != nil {
						SVProgressHUD.showErrorWithStatus("Error Joining Journey. You might have already requested to join.")
					} else {
						SVProgressHUD.showSuccessWithStatus("Sent request to join Journey")
					}
				})
			}
			
			self.pickingSelfJourneyForJourney = nil
			self.pickedJourney = nil
		}
		
		self.refreshData(nil)
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
	
	func presentSetting () {
		self.performSegueWithIdentifier("goSetting", sender: nil)
	}
	
	func openProfileImage () {
		if self.blackBackdropView == nil {
			if self.shownUser === currentUser! {
				mainNavigationDelegate.hideNavigationBar()
			}
			
			self.showProfileImage()
		} else {
			if self.shownUser === currentUser! {
				mainNavigationDelegate.showNavigationBar()
			}
			
			self.hideProfileImage()
		}
	}
	
	func showProfileImage () {
		let v: UIView = navigationController!.view
		
		let profileCell: FSProfileTableViewCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as FSProfileTableViewCell
		
		self.blackBackdropView = UIView(frame: CGRectMake(v.frame.origin.x, v.frame.origin.y, v.frame.size.width, v.frame.size.height))
		self.profileImageView = UIImageView(image: profileCell.profileImageView.image)
		
		self.blackBackdropView!.backgroundColor = UIColor.blackColor()
		
		let aspectRatio = self.profileImageView!.image!.size.height / self.profileImageView!.image!.size.width
		let height = v.frame.size.width * aspectRatio
		self.profileImageView!.frame = CGRectMake(0, v.frame.size.height / 2 - height / 2, v.frame.width, height)
		
		self.profileImageView!.userInteractionEnabled = true
		self.blackBackdropView!.userInteractionEnabled = true
		
		self.blackBackdropView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "openProfileImage"))
		self.profileImageView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "openProfileImage"))
		
		self.blackBackdropView!.alpha = 0
		self.profileImageView!.alpha = 0
		
		v.addSubview(self.blackBackdropView!)
		v.addSubview(self.profileImageView!)
		
		UIView.animateWithDuration(0.25, animations: {
			self.blackBackdropView!.alpha = 1
			self.profileImageView!.alpha = 1
		})
	}
	
	func hideProfileImage () {
		UIView.animateWithDuration(0.25, animations: {
			self.blackBackdropView!.alpha = 0
			self.profileImageView!.alpha = 0
		})
		
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.35 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { () -> Void in
			self.blackBackdropView!.removeFromSuperview()
			self.profileImageView!.removeFromSuperview()
			
			self.blackBackdropView!.removeGestureRecognizer(self.profileTapGestureRecognizer)
			self.profileImageView!.removeGestureRecognizer(self.profileTapGestureRecognizer)
			
			self.blackBackdropView = nil
			self.profileImageView = nil
		})
	}

	func refreshData (sender: AnyObject?) {
		if currentUser == nil || currentUser!._id == nil {
			return
		}
		
		var callback: (err: NSError?, data: [Journey]) -> Void = { (err: NSError?, data: [Journey]) -> Void in
			if err != nil {
				self.refreshControl!.endRefreshing()
				SVProgressHUD.showErrorWithStatus("Failed to load user data: " + err!.description)
				return
			}
			
			let calendar: NSCalendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)!
			let components: NSDateComponents = calendar.components(NSCalendarUnit.YearCalendarUnit|NSCalendarUnit.MonthCalendarUnit|NSCalendarUnit.DayCalendarUnit, fromDate: NSDate())
			components.hour = 0
			var timeIntervalNow: NSTimeInterval = calendar.dateFromComponents(components)!.timeIntervalSince1970
			
			self.journeys = []
			self.pastJourneys = []
			for j in data {
				if j.startDate == nil {
					self.journeys.append(j)
					continue
				}
				
				if timeIntervalNow > j.startDate!.timeIntervalSince1970 {
					if self.presentedFromElsewhere != true {
						self.pastJourneys.append(j)
					}
				} else {
					self.journeys.append(j)
				}
			}
			
			self.refreshControl!.endRefreshing()
			self.tableView.reloadData()
		}
		
		var u = self.shownUser
		if presentedFromElsewhere {
			Journey.getUserJourneys(shownUser, callback: callback)
			u = shownUser
			
			u.getMutualFriends(shownUser, callback: { (err: NSError?, friends: [User]) -> Void in
				if err != nil {
					return
				}
				
				self.mutualFriends = friends
				self.tableView.reloadSections(NSIndexSet(index: 4), withRowAnimation: UITableViewRowAnimation.Automatic)
			})
		} else {
			JourneyPassenger.getMyJourneyRequests({ (err: NSError?, data: [JourneyPassenger]) -> Void in
				if err != nil {
					return
				}
				
				self.myPendingRequests = data
				
				var iDone = 0
				for req in self.myPendingRequests {
					req.journey.getOwner({ () -> Void in
						if ++iDone == self.myPendingRequests.count {
							self.tableView.reloadData()
						}
					})
				}
				
				self.tableView.reloadData()
			})
			
			JourneyPassenger.getAllJourneyRequests({ (err: NSError?, data: [JourneyPassenger]) -> Void in
				if err != nil {
					return
				}
				
				self.pendingRequests = data
				
				var iDone = 0
				for req in self.pendingRequests {
					req.journey.getOwner({ () -> Void in
						if ++iDone == self.pendingRequests.count {
							self.tableView.reloadData()
						}
					})
				}
				
				self.tableView.reloadData()
			})
			
			Journey.getMyJourneys(callback)
		}
		
		u.averageRating({ (err: NSError?, rating: Double?) -> Void in
			if err != nil {
				return
			}
			
			self.driverRating = rating
			self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
		})
	}
	
    //MARK: - TableView Delegate Method
    
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 6
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0:
			return 1
		case 3:
			return journeys.count
		case 4:
			return mutualFriends.count > 0 ? 1 : 0
		case 5:
			return pastJourneys.count
		case 2:
			return myPendingRequests.count
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
			
			if self.driverRating != nil {
				c.ratingLabel.font = UIFont(awesomeFontOfSize: 17.0)
				var stars: String = ""
				
				for var i = 0; i < Int(ceil(self.driverRating!)); i++ {
					var starEnum = FAIcon.FAStar
					
					if i == Int(round(self.driverRating!)) {
						starEnum = FAIcon.FAStarHalf
					}
					
					stars = stars + NSString.fontAwesomeIconStringForEnum(starEnum)
				}
				
				c.ratingLabel.text = NSString(format: "Rating: %@", stars)
			}
			
			var url = NSURL(string: shownUser.picture!.url)
			c.profileImageView.sd_setImageWithURL(url!)
			c.profileImageView.layer.cornerRadius = 45
			c.profileImageView.layer.masksToBounds = true
			c.profileImageView.layer.shouldRasterize = true
			c.profileImageView.addGestureRecognizer(self.profileTapGestureRecognizer)
			c.profileImageView.userInteractionEnabled = true
			c.delegate = self
			c.nameLabel.text = shownUser.name
			c.selectionStyle = UITableViewCellSelectionStyle.None
			
			return cell!
		} else if indexPath.section == 1 {
			var req = pendingRequests[indexPath.row]
			
			var cell: AcceptJourneyRequestTableViewCell? = tableView.dequeueReusableCellWithIdentifier("acceptJourneyRequest", forIndexPath: indexPath) as? AcceptJourneyRequestTableViewCell
			if cell == nil {
				cell = AcceptJourneyRequestTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "acceptJourneyRequest")
			}
			
			cell!.journeyName.text = req.user.name
			
			if req.requested != nil {
				cell!.requestedLabel.text = "Requested on " + requestedJourneyDateFormatter.stringFromDate(req.requested!)
			} else {
				cell!.requestedLabel.text = ""
			}
			
			if req.journey.ownerObj != nil {
				var url = NSURL(string: req.user.picture!.url)
				cell!.profileImageView.sd_setImageWithURL(url!)
				cell!.profileImageView.layer.cornerRadius = 25
				cell!.profileImageView.layer.masksToBounds = true
				cell!.profileImageView.layer.shouldRasterize = true
			}
			
			cell!.delegate = self
			
			return cell!
		} else if indexPath.section == 2 {
			var req = myPendingRequests[indexPath.row]
			
			var cell: JourneyRequestTableViewCell? = tableView.dequeueReusableCellWithIdentifier("journeyRequest", forIndexPath: indexPath) as? JourneyRequestTableViewCell
			if cell == nil {
				cell = JourneyRequestTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "journeyRequest")
			}
			
			cell!.journeyName.text = req.journey.ownerObj!.name
			
			if req.requested != nil {
				cell!.requestedLabel.text = "Requested on " + requestedJourneyDateFormatter.stringFromDate(req.requested!)
			} else {
				cell!.requestedLabel.text = ""
			}
			
			if req.journey.ownerObj != nil {
				var url = NSURL(string: req.journey.ownerObj!.picture!.url)
				cell!.profileImageView.sd_setImageWithURL(url!)
				cell!.profileImageView.layer.cornerRadius = 25
				cell!.profileImageView.layer.masksToBounds = true
				cell!.profileImageView.layer.shouldRasterize = true
			}
			
			cell!.delegate = self
			
			return cell!
		} else if indexPath.section == 3 || indexPath.section == 5 {
			var list: [Journey] = journeys
			if indexPath.section == 5 {
				list = pastJourneys
			}
			
			let journey = list[indexPath.row]
			
			var cell = tableView.dequeueReusableCellWithIdentifier("Journey", forIndexPath: indexPath) as? JourneyTableViewCell
			if cell == nil {
				cell = JourneyTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Journey")
			}
			
			if presentedFromElsewhere == false {
				var deleteBtn = MGSwipeButton(title: " " + NSString.fontAwesomeIconStringForEnum(FAIcon.FATrashO) + " ", backgroundColor: UIColor.redColor())
				var editBtn = MGSwipeButton(title: " " + NSString.fontAwesomeIconStringForEnum(FAIcon.FAPencilSquareO) + " ", backgroundColor: UIColor.blueColor())
				
				deleteBtn.titleLabel!.font = UIFont(name: "FontAwesome", size: 24)!
				editBtn.titleLabel!.font = UIFont(name: "FontAwesome", size: 24)!
				
				if self.shownUser._id != nil && self.shownUser._id! == journey.owner! {
					cell!.leftButtons = indexPath.section == 3 ? [deleteBtn, editBtn] : []
				} else {
					cell!.leftButtons = indexPath.section == 3 ? [deleteBtn] : []
				}
				
				cell!.leftSwipeSettings.transition = MGSwipeTransition.TransitionDrag
				cell!.delegate = self
			}
			
			cell!.style()
			cell!.populate(journey)
			cell!.journeyNameLabel.text = journey.ownerObj!.name
			
			return cell!
		} else if indexPath.section == 4 {
			// mutual friends
			var cell = tableView.dequeueReusableCellWithIdentifier("MutualFriendCell", forIndexPath: indexPath) as? MutualFriendsTableViewCell
			
			if cell == nil {
				cell = MutualFriendsTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "MutualFriendCell")
			}
			
			for (i, friend) in enumerate(mutualFriends) {
				for subview in cell!.friendsScrollView.subviews {
					subview.removeFromSuperview()
				}
				
				mutualFriendGestureRecognizers = []
				
				var offset: Int = i * 8
				if i == 0 {
					offset = 8
				}
				
				if friend.picture != nil {
					var imgView = UIImageView(frame: CGRectMake(CGFloat(i * 70 + offset), 8, 70, 70))
					imgView.sd_setImageWithURL(NSURL(string: friend.picture!.url))
					imgView.clipsToBounds = true
					imgView.layer.cornerRadius = 70/2
					
					imgView.userInteractionEnabled = true
					
					var gestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "didReceiveTapOnMutualFriendCell:")
					imgView.addGestureRecognizer(gestureRecognizer)
					mutualFriendGestureRecognizers.append(gestureRecognizer)
					
					var nameLabel = UILabel(frame: CGRectMake(CGFloat(i * 70 + offset), 78 + 8, 70, 14))
					nameLabel.text = friend.name
					nameLabel.textColor = UIColor.whiteColor()
					nameLabel.font = UIFont.systemFontOfSize(12)
					nameLabel.textAlignment = NSTextAlignment.Center
					
					cell!.friendsScrollView.addSubview(imgView)
					cell!.friendsScrollView.addSubview(nameLabel)
				}
				
				cell!.userInteractionEnabled = true
				//cell!.friendsScrollView.contentSize = CGSizeMake(CGFloat(mutualFriends.count - 1) * 74 + 8, 70 + 16 + 14 + 20)
			}
			
			return cell!
		}
		
		return (tableView.dequeueReusableCellWithIdentifier("rightDetail", forIndexPath: indexPath) as? UITableViewCell)!
	}
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var sectionTitle: String? = self.tableView(tableView, titleForHeaderInSection: section)
        if sectionTitle == nil {
            return nil
        }
        
        var rect: CGRect = CGRectZero
        rect.size.width = tableView.frame.size.width;
        rect.size.height = self.tableView(tableView, heightForHeaderInSection: section)

        var view: UIView! = UIView(frame: rect)
        // If past journeys, section title color set gray tone color.
        if section == 4 {
            view.backgroundColor = kPastSectionTitleColor
        } else {
            view.backgroundColor = kDefaultSectionTitleColor
        }
        
        var label: UILabel! = UILabel(frame: CGRectMake(12, 0, tableView.bounds.size.width, tableView.sectionHeaderHeight))
        label.text = sectionTitle
        label.shadowOffset = CGSizeMake(0, 1)
        label.shadowColor = UIColor.grayColor()
        label.backgroundColor = UIColor.clearColor()
        label.textColor = UIColor.whiteColor()
        label.font = UIFont.boldSystemFontOfSize(16)
        
        view.addSubview(label)
        
        return view
    }
	
	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if section == 3 {
			return "Current Journeys"
		}
		if section == 5 {
			return self.pastJourneys.count > 0 ? "Past Journeys" : nil
		}
		if section == 2 {
			return self.myPendingRequests.count > 0 ? "Pending Requests" : nil
		}
		if section == 1 {
			return self.pendingRequests.count > 0 ? "Journey Requests" : nil
		}
		if section == 4 {
			return self.mutualFriends.count > 0 ? "Mutual Friends" : nil
		}
		
		return nil
	}

	override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		var headerHeight : CGFloat = tableView.sectionHeaderHeight
		
		if section == 5 {
			return self.pastJourneys.count > 0 ? headerHeight : 0
		}
		if section == 3 {
			return headerHeight
		}
		if section == 2 {
			return self.myPendingRequests.count > 0 ? headerHeight : 0
		}
		if section == 1 {
			return self.pendingRequests.count > 0 ? headerHeight : 0
		}
		if section == 4 {
			return self.mutualFriends.count > 0 ? headerHeight : 0
		}
		
		return 0
	}
	
	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		if indexPath.section == 0 {
			return 120.0
		} else if indexPath.section == 1 || indexPath.section == 2 {
			return 66.0
		} else if indexPath.section == 4 {
			return 70 + 16 + 14 + 16
		} else {
			return 126.0
		}
	}
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if cell.respondsToSelector(Selector("setSeparatorInset:")) {
            cell.separatorInset = UIEdgeInsetsZero
        }
        if cell.respondsToSelector(Selector("setLayoutMargins:")) {
            cell.layoutMargins = UIEdgeInsetsZero
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
		if indexPath.section == 1 {
			var req = pendingRequests[indexPath.row]
			SVProgressHUD.showProgress(0, status: "Loading Message..", maskType: SVProgressHUDMaskType.Black)
			
			findMessageList(req.user._id!, { (list: MessageList?) -> Void in
				SVProgressHUD.dismiss()
				self.performSegueWithIdentifier("openMessages", sender: list)
			})
			
			return
		}
		
		if presentedFromElsewhere && indexPath.section == 3 {
			var journey = journeys[indexPath.row]
			
			SVProgressHUD.showProgress(1.0, status: "Requesting to Join", maskType: SVProgressHUDMaskType.Black)
			
			if journey.isDriver == false {
				// pick one of my own journeys
				// weirdfuckingnamebutsowhat
				self.pickingSelfJourneyForJourney = journey
				self.performSegueWithIdentifier("pickJourney", sender: nil)
				return
			}
			
			journey.requestJoin({ (err: NSError?) -> Void in
				if err != nil {
					SVProgressHUD.showErrorWithStatus("Error Joining Journey. You might have already requested to join.")
				} else {
					SVProgressHUD.showSuccessWithStatus("Sent request to join Journey")
				}
			})
		} else if indexPath.section == 3 || indexPath.section == 5 {
			// Open passengers list
			var journey = indexPath.section == 3 ? journeys[indexPath.row] : pastJourneys[indexPath.row];
			if journey.isDriver == false {
				tableView.deselectRowAtIndexPath(indexPath, animated: true)
				return
			}
			
			self.performSegueWithIdentifier("openPassengers", sender: journey)
			return
		}
		
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}
	
	func openCars(sender: UIButton) {
		self.performSegueWithIdentifier("openCars", sender: nil)
	}
	
	func pageRootTitle() -> NSString? {
		return "Hike"
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		self.isInSegue = true
		mainNavigationDelegate.hideNavigationBar()
		SVProgressHUD.dismiss()
		
		if segue.identifier == "openMessages" {
			var vc: MessagesViewController = segue.destinationViewController as MessagesViewController
			vc.list = sender as MessageList
		} else if segue.identifier == "openPassengers" {
			var vc: PassengersTableViewController = segue.destinationViewController as PassengersTableViewController
			vc.journey = sender as Journey
		} else if segue.identifier == "addJourney" && sender != nil {
			var vc: AddJourneyTableViewController = (segue.destinationViewController as UINavigationController).viewControllers[0] as AddJourneyTableViewController
			vc.journey = sender as Journey
		} else if segue.identifier == "openCars" {
			if presentedFromElsewhere == true {
				var vc: CarsTableViewController = segue.destinationViewController as CarsTableViewController
				vc.user = shownUser
			}
		} else if segue.identifier == "pickJourney" {
			var vc: PickJourneyViewCtrl = (segue.destinationViewController as UINavigationController).viewControllers[0] as PickJourneyViewCtrl
			vc.delegate = self
		}
	}
	
	func openMessageNotification(listId: NSString) {
		MessageList.getList(listId, callback: { (err: NSError?, data: MessageList?) -> Void in
			if data == nil {
				return
			}
			
			self.performSegueWithIdentifier("openMessages", sender: data!)
		})
	}
	
	func openJourneyNotification(reload: Bool, info: [NSString : AnyObject]) {
		if reload != false {
			self.refreshData(nil)
		}
	}
	
	func swipeTableCell(cell: MGSwipeTableCell!, canSwipe direction: MGSwipeDirection) -> Bool {
		return direction == MGSwipeDirection.LeftToRight
	}
	
	func swipeTableCell(cell: MGSwipeTableCell!, tappedButtonAtIndex index: Int, direction: MGSwipeDirection, fromExpansion: Bool) -> Bool {
		var cell: JourneyTableViewCell = cell as JourneyTableViewCell
		var indexPath: NSIndexPath = self.tableView.indexPathForCell(cell as UITableViewCell)!
		
		let journey = self.journeys[indexPath.row]
		
		if index == 0 {
			// Delete
			if self.shownUser._id! != journey.owner! {
				// Delete the passenger request.
				SVProgressHUD.showProgress(1.0, status: "Removing..", maskType: SVProgressHUDMaskType.Black)
				
				journey.getPassengers({ (err: NSError?, data: [JourneyPassenger]) -> Void in
					var found: JourneyPassenger?
					
					for d in data {
						if d.user._id! == self.shownUser._id! {
							found = d
							break
						}
					}
					
					if found == nil {
						return SVProgressHUD.showErrorWithStatus("Could not find passenger. Reload data!")
					}
					
					found!.rejectRequest({ (err: NSError?) -> Void in
						if err != nil {
							return SVProgressHUD.showErrorWithStatus("Could not remove passenger.")
						}
						
						SVProgressHUD.dismiss()
						self.refreshData(nil)
					})
				})
				
				return true
			}
			
			SVProgressHUD.showProgress(1.0, status: "Deleting...", maskType: SVProgressHUDMaskType.Black)
			journey.delete({ (err: NSError?, data: AnyObject?) -> Void in
				SVProgressHUD.dismiss()
				self.refreshData(nil)
			})
		} else if index == 1 {
			self.performSegueWithIdentifier("addJourney", sender: journey)
		}
		
		return true
	}
	
	// JourneyRequestDelegate
	
	func JourneyRequestDidPressDelete(cell: JourneyRequestTableViewCell) {
		var req: JourneyPassenger? = self.getRequestFromCollection(cell as UITableViewCell, collection: self.myPendingRequests as [AnyObject]) as? JourneyPassenger
		if req == nil {
			return
		}
		
		SVProgressHUD.showProgress(1.0, status: "Loading...", maskType: SVProgressHUDMaskType.Black)
		req!.rejectRequest({ (err: NSError?) -> Void in
			if err != nil {
				SVProgressHUD.showErrorWithStatus("Error Loading.")
				return
			}
			
			SVProgressHUD.dismiss()
			self.refreshData(nil)
		})
	}
	
	// AcceptJourneyRequestDelegate
	
	func AcceptJourneyRequestDidPressAccept(cell: AcceptJourneyRequestTableViewCell) {
		// accept journey request
		var req: JourneyPassenger? = self.getRequestFromCollection(cell as UITableViewCell, collection: self.pendingRequests as [AnyObject]) as? JourneyPassenger
		if req == nil {
			return
		}
		
		SVProgressHUD.showProgress(1.0, status: "Loading...", maskType: SVProgressHUDMaskType.Black)
		req!.approveRequest({ (err: NSError?) -> Void in
			if err != nil {
				SVProgressHUD.showErrorWithStatus("Error Loading.")
				return
			}
			
			SVProgressHUD.dismiss()
			self.refreshData(nil)
		})
	}
	
	func AcceptJourneyRequestDidPressReject(cell: AcceptJourneyRequestTableViewCell) {
		// reject journey request
		var req: JourneyPassenger? = self.getRequestFromCollection(cell as UITableViewCell, collection: self.pendingRequests as [AnyObject]) as? JourneyPassenger
		if req == nil {
			return
		}
		
		req!.rejectRequest({ (err: NSError?) -> Void in
			if err != nil {
				SVProgressHUD.showErrorWithStatus("Error Loading.")
				return
			}
			
			SVProgressHUD.dismiss()
			self.refreshData(nil)
		})
	}
	
	func getRequestFromCollection (cell: UITableViewCell, collection: [AnyObject]) -> AnyObject? {
		var indexPath: NSIndexPath? = self.tableView.indexPathForCell(cell as UITableViewCell)
		
		if indexPath == nil {
			return nil
		}
		
		return collection[indexPath!.row]
	}
	
	func didReceiveTapOnMutualFriendCell(recognizer: UITapGestureRecognizer) {
		var friend: User? = nil
		
		for (i, rec) in enumerate(mutualFriendGestureRecognizers) {
			if rec === recognizer {
				friend = mutualFriends[i]
				break
			}
		}
		
		if friend == nil {
			return
		}
		
		SVProgressHUD.showProgress(1.0, status: "Loading Message..", maskType: SVProgressHUDMaskType.Black)
		
		findMessageList(friend!._id!, { (list: MessageList?) -> Void in
			self.performSegueWithIdentifier("openMessages", sender: list)
		})
	}
	
	//PRAGMA mark: PickJourneyDelegate thing
	
	func pickJourneyViewDidPickJourney(journey: Journey) {
		self.pickedJourney = journey
	}
	
}

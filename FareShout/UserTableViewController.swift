
import UIKit

class UserTableViewController: UITableViewController, FSProfileTableViewCellDelegate, PageRootDelegate, MGSwipeTableCellDelegate, JourneyRequestDelegate, AcceptJourneyRequestDelegate {
    
    // Section title color constant variables.
    let kDefaultSectionTitleColor : UIColor! = UIColor(red: 103/255.0, green: 0/255.0, blue: 10/255.0, alpha: 1)
    let kPastSectionTitleColor : UIColor! = UIColor.grayColor()
	
	var journeys: [Journey] = []
	var pastJourneys: [Journey] = []
	var myPendingRequests: [JourneyPassenger] = []
	var pendingRequests: [JourneyPassenger] = []
	
	var didAppear: Bool = false
	var isInSegue: Bool = false
	
	// set to true before loading to indicate the view isn't loaded from UIPage thing
	var presentedFromElsewhere = false
	var shownUser: User!
	
	let requestedJourneyDateFormatter: NSDateFormatter = NSDateFormatter()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.requestedJourneyDateFormatter.dateFormat = "dd/MM/yyyy"
		
		self.navigationController!.navigationBar.translucent = false
		
		self.refreshControl = UIRefreshControl()
		self.refreshControl!.addTarget(self, action: "refreshData:", forControlEvents: UIControlEvents.ValueChanged)
		
		self.tableView.registerNib(UINib(nibName: "JourneyTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "Journey")
		self.tableView.registerNib(UINib(nibName: "FSProfileTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "profileCell")
		self.tableView.registerNib(UINib(nibName: "JourneyRequestTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "journeyRequest")
		self.tableView.registerNib(UINib(nibName: "AcceptJourneyRequestTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "acceptJourneyRequest")
        
        var image : UIImage! = UIImage(named: "BackGround")
        var imageView : UIImageView! = UIImageView(image: image)
        imageView.frame = UIScreen.mainScreen().bounds
        self.tableView.backgroundView = imageView
        self.tableView.separatorColor = UIColor(red: 145/255.0, green: 101/255.0, blue: 105/255.0, alpha: 1)
		
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
		
		self.refreshData(nil)
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
	
	func refreshData (sender: AnyObject?) {
		var callback: (err: NSError?, data: [Journey]) -> Void = { (err: NSError?, data: [Journey]) -> Void in
			var timeIntervalNow: NSTimeInterval = NSDate().timeIntervalSince1970
			
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
		
		if presentedFromElsewhere {
			Journey.getUserJourneys(shownUser, callback: callback)
		} else {
			JourneyPassenger.getMyJourneyRequests({ (err: NSError?, data: [JourneyPassenger]) -> Void in
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
	}
	
    //MARK: - TableView Delegate Method
    
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 5
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0:
			return 1
		case 3:
			return journeys.count
		case 4:
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
			
			var cell: AcceptJourneyRequestTableViewCell? = tableView.dequeueReusableCellWithIdentifier("acceptJourneyRequest", forIndexPath: indexPath) as? AcceptJourneyRequestTableViewCell
			if cell == nil {
				cell = AcceptJourneyRequestTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "acceptJourneyRequest")
			}
			
			if req.journey.ownerObj != nil {
				cell!.journeyName.text = req.journey.ownerObj!.first_name! + " " + req.journey.ownerObj!.last_name!.substringToIndex(1)
			}
			
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
		} else if indexPath.section == 2 {
			var req = myPendingRequests[indexPath.row]
			
			var cell: JourneyRequestTableViewCell? = tableView.dequeueReusableCellWithIdentifier("journeyRequest", forIndexPath: indexPath) as? JourneyRequestTableViewCell
			if cell == nil {
				cell = JourneyRequestTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "journeyRequest")
			}
			
			if req.journey.ownerObj != nil {
				cell!.journeyName.text = req.journey.ownerObj!.first_name! + " " + req.journey.ownerObj!.last_name!.substringToIndex(1)
			}
			
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
		} else if indexPath.section == 3 || indexPath.section == 4 {
			var list: [Journey] = journeys
			if indexPath.section == 4 {
				list = pastJourneys
			}
			
			var journey = list[indexPath.row]
			
			var cell = tableView.dequeueReusableCellWithIdentifier("Journey", forIndexPath: indexPath) as? JourneyTableViewCell
			if cell == nil {
				cell = JourneyTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Journey")
			}
			
			if presentedFromElsewhere == false {
				var deleteBtn = MGSwipeButton(title: " " + NSString.fontAwesomeIconStringForEnum(FAIcon.FATrashO) + " ", backgroundColor: UIColor.redColor())
				var editBtn = MGSwipeButton(title: " " + NSString.fontAwesomeIconStringForEnum(FAIcon.FAPencilSquareO) + " ", backgroundColor: UIColor.blueColor())
				
				deleteBtn.titleLabel!.font = UIFont(name: "FontAwesome", size: 24)!
				editBtn.titleLabel!.font = UIFont(name: "FontAwesome", size: 24)!
				
				if currentUser!._id! == journey.owner! {
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
		if section == 4 {
			return self.pastJourneys.count > 0 ? "Past Journeys" : nil
		}
		if section == 2 {
			return self.myPendingRequests.count > 0 ? "Pending Requests" : nil
		}
		if section == 1 {
			return self.pendingRequests.count > 0 ? "Journey Requests" : nil
		}
		
		return nil
	}

	override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		var headerHeight : CGFloat = tableView.sectionHeaderHeight
		
		if section == 4 {
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
		
		return 0
	}
	
	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		if indexPath.section == 0 {
			return 120.0
		} else if indexPath.section == 1 || indexPath.section == 2 {
			return 66.0
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
		if presentedFromElsewhere && indexPath.section == 3 {
			var journey = journeys[indexPath.row]
			
			SVProgressHUD.showProgress(1.0, status: "Requesting to Join", maskType: SVProgressHUDMaskType.Black)
			
			journey.requestJoin({ (err: NSError?) -> Void in
				if err != nil {
					SVProgressHUD.showErrorWithStatus("Error Joining Journey. Perhaps already requested.")
				} else {
					SVProgressHUD.showSuccessWithStatus("Sent request to join Journey")
				}
			})
		} else if indexPath.section == 3 {
			// Open passengers list
			self.performSegueWithIdentifier("openPassengers", sender: journeys[indexPath.row])
			return
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
		
		if segue.identifier == "openPassengers" {
			var vc: PassengersTableViewController = segue.destinationViewController as PassengersTableViewController
			vc.journey = sender as Journey
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
			if currentUser!._id! != journey.owner! {
				// Delete the passenger request.
				SVProgressHUD.showProgress(1.0, status: "Removing..", maskType: SVProgressHUDMaskType.Black)
				
				journey.getPassengers({ (err: NSError?, data: [JourneyPassenger]) -> Void in
					var found: JourneyPassenger?
					
					for d in data {
						if d.user._id! == currentUser!._id! {
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
	
}


import UIKit

class MessagesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	
	var list: MessageList!
	
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var textField: UITextField!
	@IBOutlet weak var sendButton: UIButton!
	@IBOutlet weak var textHolderView: UIView!
	@IBOutlet weak var textHolderBottomLayoutGuide: NSLayoutConstraint!
	
	var toolbar: UIToolbar!
	var refreshControl: UIRefreshControl!
	var originalHeight: CGFloat!
	var ignoreKeyboardNotifications: Bool = false
	
	var tapGestureRecognizer: UITapGestureRecognizer!
	var titleView: UIView!
	
	var timeFormatter: NSDateFormatter!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		timeFormatter = NSDateFormatter()
		timeFormatter.dateFormat = "hh:mm"
		
		if list.receiver._id == currentUser!._id! {
			self.navigationItem.title = list.sender.name
		} else {
			self.navigationItem.title = list.receiver.name
		}
		
		var buttonTitle = NSString.fontAwesomeIconStringForEnum(FAIcon.FAcar)
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: buttonTitle, style: UIBarButtonItemStyle.Plain, target: self, action: "titleTap:")
		var attributes: [NSObject: AnyObject] = [
			NSFontAttributeName: UIFont(name: "FontAwesome", size: 22)!
		]
		self.navigationItem.rightBarButtonItem!.setTitleTextAttributes(attributes, forState: UIControlState.Normal)
		
		if !didRequestForNotifications {
			var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
			appDelegate.requestForNotifications()
		}
		
		self.tableView.delegate = self
		self.tableView.dataSource = self

		self.refreshControl = UIRefreshControl()
		self.refreshControl.addTarget(self, action: "refreshData:", forControlEvents: UIControlEvents.ValueChanged)
		self.refreshControl.tintColor = UIColor.whiteColor()
		
		self.tableView.addSubview(self.refreshControl)
		
		self.sendButton.addTarget(self, action: "sendMessage:", forControlEvents: UIControlEvents.TouchUpInside)
		self.textField.placeholder = "Message.."
		self.textField.addTarget(self, action: "valueChanged:", forControlEvents: UIControlEvents.EditingChanged)
		self.textField.keyboardType = UIKeyboardType.Default
		self.textField.autocapitalizationType = UITextAutocapitalizationType.Sentences
		self.textField.autocorrectionType = UITextAutocorrectionType.Default
		
		self.tableView.registerNib(UINib(nibName: "LeftChatTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "LeftChatCell")
		self.tableView.registerNib(UINib(nibName: "RightChatTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "RightChatCell")
		self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
		//self.tableView.backgroundColor = UIColor(red: 113/255, green: 0, blue: 2/255, alpha: 1.0)
        var image : UIImage! = UIImage(named: "BackGround")
        var imageView : UIImageView! = UIImageView(image: image)
        imageView.frame = UIScreen.mainScreen().bounds
        self.tableView.backgroundView = imageView
        self.tableView.separatorColor = UIColor(red: 145/255.0, green: 101/255.0, blue: 105/255.0, alpha: 1)
        //self.tableView.backgroundView = nil
		
		tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "titleTap:")
		tapGestureRecognizer.numberOfTapsRequired = 1
		titleView = UIView(frame: CGRectMake(self.navigationController!.navigationBar.frame.width / 4, 0, self.navigationController!.navigationBar.frame.width / 2, 44))
		titleView.backgroundColor = UIColor.clearColor()
		titleView.addGestureRecognizer(tapGestureRecognizer)
		self.navigationController!.navigationBar.addSubview(titleView)
		
		self.sendButton.enabled = false
		self.refreshData(false)
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		self.refreshNotificationBadgeCount()
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		var notificationCenter = NSNotificationCenter.defaultCenter()
		notificationCenter.addObserver(self, selector: "keyboardWillShowNotification:", name: UIKeyboardWillShowNotification, object: nil)
		notificationCenter.addObserver(self, selector: "keyboardWillHideNotification:", name: UIKeyboardWillHideNotification, object: nil)
		notificationCenter.addObserver(self, selector: "didReceiveMessage:", name: "ReceivedMessage", object: nil)
		
		tapGestureRecognizer.enabled = true
		self.navigationController!.navigationBar.addSubview(titleView)
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		
		// Prevents inception and going to Limbo
		tapGestureRecognizer.enabled = false
		titleView.removeFromSuperview()
		
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
	func refreshNotificationBadgeCount () {
		doRequest(makeRequest("/messages/" + self.list._id + "/read", "PUT"), { (err: NSError?, data: AnyObject?) -> Void in
			let json: [NSString: AnyObject]? = data as? [NSString: AnyObject]
			if json != nil {
				var unreadCount: Int? = json!["unreadCount"] as? Int
				if unreadCount != nil {
					UIApplication.sharedApplication().applicationIconBadgeNumber = unreadCount!
				}
			}
		}, nil)
	}
	
	func titleTap (sender: AnyObject) {
		self.performSegueWithIdentifier("showUser", sender: nil)
	}
	
	func sendMessage (sender: AnyObject?) {
		var message = Message(list: list)
		message.message = self.textField.text as NSString
		message.sender = currentUser!._id!
		message.sent = NSDate()
		
		SVProgressHUD.showProgress(0, status: "Sending..", maskType: SVProgressHUDMaskType.Black)
		message.sendMessage({ (err: NSError?, data: AnyObject?) -> Void in
			self.textField.text = ""
			self.sendButton.enabled = false
			
			self.ignoreKeyboardNotifications = true
			self.textField.resignFirstResponder()
			self.textField.becomeFirstResponder()
			self.ignoreKeyboardNotifications = false
			
			SVProgressHUD.showSuccessWithStatus("Sent.")
			self.refreshData(nil)
		})
	}
	
	func valueChanged (sender: AnyObject?) {
		var val = self.textField.text as NSString
		
		self.sendButton.enabled = val.length > 0
	}
	
	func keyboardWillShowNotification (notification: NSNotification) {
		scrollKeyboard(notification, directionUp: true)
	}
	
	func keyboardWillHideNotification (notification: NSNotification) {
		scrollKeyboard(notification, directionUp: false)
	}
	
	func scrollKeyboard (notification: NSNotification, directionUp: Bool) {
		if ignoreKeyboardNotifications == true {
			return
		}
		
		var userInfo: NSDictionary = notification.userInfo!
		
		var duration: NSTimeInterval = userInfo.objectForKey(UIKeyboardAnimationDurationUserInfoKey) as NSTimeInterval
		
//		var curveRawValue = userInfo.objectForKey(NSString(format: UIKeyboardAnimationCurveUserInfoKey)) as NSNumber
		var curve: UIViewAnimationCurve = UIViewAnimationCurve.EaseOut//UIViewAnimationCurve(rawValue: Int(curveRawValue))!
		
		var kbFrameValue = userInfo[UIKeyboardFrameEndUserInfoKey] as NSValue
		var kbFrame = kbFrameValue.CGRectValue()
		
		UIView.animateWithDuration(duration, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
			var height: CGFloat = self.tableView.contentSize.height
			
			if directionUp {
				self.originalHeight = height
				height -= kbFrame.size.height
				self.textHolderBottomLayoutGuide.constant = kbFrame.size.height
			} else {
				height = self.originalHeight
				self.textHolderBottomLayoutGuide.constant = 0
			}
			
			self.tableView.layoutIfNeeded()
			self.textHolderView.layoutIfNeeded()
			
			self.tableView.contentSize = CGSizeMake(self.tableView.contentSize.width, height)
			self.tableView.reloadData()
			if self.list.messages.count > 0 {
				self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.list.messages.count-1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)
			}
		}, completion: { (something: Bool) -> Void in
		})
	}
	
	func refreshData (sender: AnyObject?) {
		self.refreshControl.endRefreshing()
		
		var animated: Bool!
		var animatedMaybe = sender as? Bool
		if animatedMaybe != nil {
			animated = animatedMaybe!
		} else {
			animated = true
		}
		
		self.list.getMessages({ (err: NSError?, data: [Message]) -> Void in
			self.refreshControl.endRefreshing()
			self.tableView.reloadData()
			if self.list.messages.count > 0 {
				self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.list.messages.count-1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: animated)
			}
		})
	}
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return list.messages.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let message: Message = list.messages[indexPath.row]
		let bgColor: UIColor = UIColor(red: 241/255, green: 245/255, blue: 253/255, alpha: 1.0)
		let textColor: UIColor = UIColor(red: 100/255, green: 100/255, blue: 100/255, alpha: 1.0)
		let cornerRadius: CGFloat = 26/2
		
		if message.sender == currentUser!._id {
			var cell: RightChatTableViewCell? = tableView.dequeueReusableCellWithIdentifier("RightChatCell", forIndexPath: indexPath) as? RightChatTableViewCell
			
			if cell == nil {
				cell = RightChatTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "RightChatCell")
			}
			
			cell!.backgroundView = nil
			cell!.backgroundColor = UIColor.clearColor()
			cell!.label.text = message.message
			cell!.label.textColor = textColor
			cell!.bgView.layer.backgroundColor = bgColor.CGColor
			cell!.bgView.layer.cornerRadius = cornerRadius
			cell!.timeLabel.text = timeFormatter.stringFromDate(message.sent)
			
			cell!.selectionStyle = UITableViewCellSelectionStyle.None
			
			return cell!
		} else {
			var cell: LeftChatTableViewCell? = tableView.dequeueReusableCellWithIdentifier("LeftChatCell", forIndexPath: indexPath) as? LeftChatTableViewCell
			
			if cell == nil {
				cell = LeftChatTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "LeftChatCell")
			}
			
			var user = list.receiver
			if user._id != message.sender {
				user = list.sender
			}
			
			var url: NSURL = NSURL(string: user.picture!.url)!
			cell!.profileImageView.sd_setImageWithURL(url)
			cell!.profileImageView.layer.masksToBounds = true
			cell!.profileImageView.layer.cornerRadius = 35/2
			cell!.profileImageView.layer.shouldRasterize = true
			
			cell!.timeLabel.text = timeFormatter.stringFromDate(message.sent)
			
			cell!.backgroundView = nil
			cell!.backgroundColor = UIColor.clearColor()
			cell!.label.text = message.message
			cell!.label.textColor = UIColor.whiteColor()
			cell!.bgView.layer.backgroundColor = UIColor.blackColor().CGColor
			cell!.bgView.layer.cornerRadius = cornerRadius
			
			cell!.selectionStyle = UITableViewCellSelectionStyle.None
			
			return cell!
		}
	}
	
	func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
		let message: Message = list.messages[indexPath.row]
		
		var attributes: [NSObject: AnyObject] = [
			NSFontAttributeName: UIFont.systemFontOfSize(18)
		]
		
		var isSender = message.sender == currentUser!._id
		var maxWidth: CGFloat = isSender ? 84 : 84 + 8 + 35
		
		var expectedRect: CGRect = message.message.boundingRectWithSize(CGSizeMake(tableView.frame.width - maxWidth, 99999999), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: attributes, context: nil)
		
		if isSender {
			var c: RightChatTableViewCell = cell as RightChatTableViewCell
			
			c.bgViewWidth.constant = expectedRect.width + 16
		} else {
			var c: LeftChatTableViewCell = cell as LeftChatTableViewCell
			
			c.bgViewWidth.constant = expectedRect.width + 16
		}
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		var message: Message = list.messages[indexPath.row]
		
		var attributes: [NSObject: AnyObject] = [
			NSFontAttributeName: UIFont.systemFontOfSize(18)
		]
		//var expectedSize: CGSize = message.message.sizeWithAttributes(attributes)
		var expectedRect: CGRect = message.message.boundingRectWithSize(CGSizeMake(tableView.frame.width - 99, 99999999), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: attributes, context: nil)
		
		return expectedRect.height + 16 + 16
	}
	
	func didReceiveMessage(notification: NSNotification) {
		var info = notification.userInfo!
		
		if info["list"] as NSString == list._id {
			self.refreshData(nil)
		}
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "showUser" {
			var vc: UserTableViewController = segue.destinationViewController as UserTableViewController
			vc.presentedFromElsewhere = true
			
			if list.receiver._id == currentUser!._id! {
				vc.shownUser = list.sender
			} else {
				vc.shownUser = list.receiver
			}
			
			// sets 'Back' for the pushed vc
			self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Bordered, target: nil, action: nil)
		}
	}
	
}

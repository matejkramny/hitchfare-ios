
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
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if list.receiver._id == currentUser!._id! {
			self.navigationItem.title = list.sender.name
		} else {
			self.navigationItem.title = list.receiver.name
		}
		
		self.tableView.delegate = self
		self.tableView.dataSource = self

		self.refreshControl = UIRefreshControl()
		self.refreshControl.addTarget(self, action: "refreshData:", forControlEvents: UIControlEvents.ValueChanged)
		
		self.tableView.addSubview(self.refreshControl)
		
		self.sendButton.addTarget(self, action: "sendMessage:", forControlEvents: UIControlEvents.TouchUpInside)
		self.textField.placeholder = "Message.."
		self.textField.addTarget(self, action: "valueChanged:", forControlEvents: UIControlEvents.EditingChanged)
		self.textField.keyboardType = UIKeyboardType.Default
		self.textField.autocapitalizationType = UITextAutocapitalizationType.Sentences
		self.textField.autocorrectionType = UITextAutocorrectionType.Default
		
		self.sendButton.enabled = false
		self.refreshData(false)
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		var notificationCenter = NSNotificationCenter.defaultCenter()
		notificationCenter.addObserver(self, selector: "keyboardWillShowNotification:", name: UIKeyboardWillShowNotification, object: nil)
		notificationCenter.addObserver(self, selector: "keyboardWillHideNotification:", name: UIKeyboardWillHideNotification, object: nil)
		notificationCenter.addObserver(self, selector: "didReceiveMessage:", name: "ReceivedMessage", object: nil)
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		
		NSNotificationCenter.defaultCenter().removeObserver(self)
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
		var cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("basic", forIndexPath: indexPath) as? UITableViewCell
		
		var message: Message = list.messages[indexPath.row]
		cell!.textLabel!.text = message.message
		
		if message.sender == currentUser!._id {
			cell!.textLabel!.textAlignment = NSTextAlignment.Right
		} else {
			cell!.textLabel!.textAlignment = NSTextAlignment.Left
		}
		
		cell!.selectionStyle = UITableViewCellSelectionStyle.None
		
		return cell!
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}
	
	func didReceiveMessage(notification: NSNotification) {
		var info = notification.userInfo!
		
		if info["list"] as NSString == list._id {
			self.refreshData(nil)
		}
	}
	
}

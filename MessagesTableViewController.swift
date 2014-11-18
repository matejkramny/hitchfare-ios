
import UIKit

class MessagesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	
	var list: MessageList!
	
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var textField: UITextField!
	@IBOutlet weak var sendButton: UIButton!
	
	var toolbar: UIToolbar!
	var refreshControl: UIRefreshControl!
	var originalY: CGFloat!
	
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
		
		self.sendButton.enabled = false
		self.refreshData(nil)
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		var notificationCenter = NSNotificationCenter.defaultCenter()
		notificationCenter.addObserver(self, selector: "keyboardWillShowNotification:", name: UIKeyboardWillShowNotification, object: nil)
		notificationCenter.addObserver(self, selector: "keyboardWillHideNotification:", name: UIKeyboardWillHideNotification, object: nil)
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
		var userInfo: NSDictionary = notification.userInfo!
		
		var duration: NSTimeInterval = userInfo.objectForKey(UIKeyboardAnimationDurationUserInfoKey) as NSTimeInterval
		
//		var curveRawValue = userInfo.objectForKey(NSString(format: UIKeyboardAnimationCurveUserInfoKey)) as NSNumber
		var curve: UIViewAnimationCurve = UIViewAnimationCurve.EaseOut//UIViewAnimationCurve(rawValue: Int(curveRawValue))!
		
		var kbFrameValue = userInfo[UIKeyboardFrameEndUserInfoKey] as NSValue
		var kbFrame = kbFrameValue.CGRectValue()
		
		UIView.beginAnimations(nil, context: nil)
		UIView.setAnimationDuration(duration)
		UIView.setAnimationCurve(curve)
		
		var y: CGFloat = self.view.frame.origin.y
		
		if directionUp {
			originalY = y
			y -= kbFrame.size.height
		} else {
			y = originalY
		}
		
		self.view.frame = CGRectMake(self.view.frame.origin.x, y, self.view.frame.size.width, self.view.frame.size.height)
		
		UIView.commitAnimations()
	}
	
	func refreshData (sender: AnyObject?) {
		self.refreshControl.endRefreshing()
		
		self.list.getMessages({ (err: NSError?, data: [Message]) -> Void in
			self.refreshControl.endRefreshing()
			self.tableView.reloadData()
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
		cell!.textLabel.text = message.message
		
		if message.sender == currentUser!._id {
			cell!.textLabel.textAlignment = NSTextAlignment.Right
		} else {
			cell!.textLabel.textAlignment = NSTextAlignment.Left
		}
		
		return cell!
	}
	
}

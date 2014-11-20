
import UIKit

class HikesTableViewCell: UITableViewController, PageRootDelegate {
	
	var messages: [MessageList] = []
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.navigationController?.navigationBar.translucent = false
		
		self.refreshControl = UIRefreshControl()
		self.refreshControl!.addTarget(self, action: "refreshData:", forControlEvents: UIControlEvents.ValueChanged)
		
		self.refreshData(nil)
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		mainNavigationDelegate.showNavigationBar()
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
		var cell = tableView.dequeueReusableCellWithIdentifier("basic", forIndexPath: indexPath) as? UITableViewCell
		
		var user = messages[indexPath.row].receiver
		if user._id == currentUser!._id! {
			user = messages[indexPath.row].sender
		}
		
		cell!.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
		cell!.textLabel!.text = user.name
		
		return cell!
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		var user = messages[indexPath.row].receiver
		if user._id == currentUser!._id! {
			user = messages[indexPath.row].sender
		}
		
		findMessageList(user._id!, { (list: MessageList?) -> Void in
			self.performSegueWithIdentifier("openMessages", sender: list)
		})
	}
	
	func pageRootTitle() -> NSString? {
		return "Hike"
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		mainNavigationDelegate.hideNavigationBar()
		
		if segue.identifier == "openMessages" {
			var vc: MessagesViewController = segue.destinationViewController as MessagesViewController
			vc.list = sender as MessageList
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
		
}

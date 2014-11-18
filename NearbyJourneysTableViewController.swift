
import UIKit

class NearbyJourneysTableViewController: UITableViewController {
	
	var journeys: [Journey] = []
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSString.fontAwesomeIconStringForEnum(FAIcon.FAThumbsOUp), style: UIBarButtonItemStyle.Plain, target: self, action: "addHike:")
		
		var attributes: [NSObject: AnyObject] = [
			NSFontAttributeName: UIFont(name: "FontAwesome", size: 20)!
		]
		self.navigationItem.rightBarButtonItem?.setTitleTextAttributes(attributes, forState: UIControlState.Normal)
		
		self.refreshControl = UIRefreshControl()
		self.refreshControl!.addTarget(self, action: "refreshData:", forControlEvents: UIControlEvents.ValueChanged)
		
		self.tableView.registerNib(UINib(nibName: "JourneyTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "Journey")
		
		self.refreshData(nil)
	}
	
	func addHike (sender: AnyObject) {
		self.performSegueWithIdentifier("addJourney", sender: nil)
	}
	
	func refreshData (sender: AnyObject?) {
		Journey.getAll({ (err: NSError?, data: [Journey]) -> Void in
			self.journeys = data
			self.refreshControl!.endRefreshing()
			self.tableView.reloadData()
		})
	}
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return journeys.count
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		var cell = tableView.dequeueReusableCellWithIdentifier("Journey", forIndexPath: indexPath) as? JourneyTableViewCell
		if cell == nil {
			cell = JourneyTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Journey")
		}
		
		cell!.style()
		cell!.populate(journeys[indexPath.row])
		
		return cell!
	}
	
	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 126.0
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		var journey = journeys[indexPath.row]
		
		MessageList.getLists({ (err: NSError?, data: [MessageList]) -> Void in
			var foundList: MessageList?
			
			for list in data {
				if journey.owner! == list.receiver._id! || journey.owner! == list.sender._id! {
					foundList = list
					break
				}
			}
			
			var callback: (list: MessageList) -> Void = { (list: MessageList) -> Void in
				self.performSegueWithIdentifier("openMessages", sender: list)
			}
			
			if foundList == nil {
				MessageList.createList(journey.owner!, callback: { (err: NSError?, data: MessageList?) -> Void in
					if data != nil {
						callback(list: data!)
					}
				})
			} else {
				callback(list: foundList!)
			}
		})
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		var vc: MessagesViewController = segue.destinationViewController as MessagesViewController
		vc.list = sender as MessageList
	}
	
}

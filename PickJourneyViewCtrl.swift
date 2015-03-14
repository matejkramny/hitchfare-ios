
import UIKit

protocol PickJourneyDelegate {
	func pickJourneyViewDidPickJourney(journey: Journey)
}

class PickJourneyViewCtrl: UITableViewController {
	
	var journeys: [Journey] = []
	var delegate: PickJourneyDelegate!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.navigationItem.title = "Pick Journey to Join"
		self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancel:")
		
		self.tableView.registerNib(UINib(nibName: "JourneyTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "Journey")
		
		var image : UIImage! = UIImage(named: "BackGround")
		var imageView : UIImageView! = UIImageView(image: image)
		imageView.frame = UIScreen.mainScreen().bounds
		self.tableView.backgroundView = imageView
		
		self.tableView.separatorColor = UIColor(red: 145/255.0, green: 101/255.0, blue: 105/255.0, alpha: 1)
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		Journey.getOnlyMyJourneys({ (err: NSError?, data: [Journey]) -> Void in
			var js: [Journey] = []
			var now: NSTimeInterval = NSDate().timeIntervalSince1970
			
			for journey in data {
				if journey.startDate!.timeIntervalSince1970 > now {
					js.append(journey)
				}
			}
			
			self.journeys = js
			self.tableView.reloadData()
		})
	}
	
	func cancel(sender: AnyObject?) {
		self.dismissViewControllerAnimated(true, completion: nil)
	}
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.journeys.count
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let journey = self.journeys[indexPath.row]
		
		var cell = tableView.dequeueReusableCellWithIdentifier("Journey", forIndexPath: indexPath) as? JourneyTableViewCell
		if cell == nil {
			cell = JourneyTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Journey")
		}
		
		cell!.style()
		cell!.populate(journey)
		cell!.journeyNameLabel.text = journey.ownerObj!.name
		
		return cell!
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let journey = self.journeys[indexPath.row]
		self.delegate.pickJourneyViewDidPickJourney(journey)
		self.cancel(nil)
	}
	
	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 126.0
	}
	
}

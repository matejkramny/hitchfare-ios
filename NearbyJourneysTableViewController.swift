
import UIKit
import MapKit

class NearbyJourneysTableViewController: UITableViewController, PageRootDelegate, CLLocationManagerDelegate, FSSearchPropertiesDelegate {
	
	var journeys: [Journey] = []
	var didAppear: Bool = false
	var isInSegue: Bool = false
	var lastLocation: CLLocationCoordinate2D? = nil
	var didUpdateDataAfterLocation: Bool = false
	
	var locationManager: CLLocationManager!
	var searchAttributes: NSString?
	var searchProperties: Journey?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.navigationController?.navigationBar.translucent = false
		
		self.refreshControl = UIRefreshControl()
		self.refreshControl!.addTarget(self, action: "refreshData:", forControlEvents: UIControlEvents.ValueChanged)
		self.refreshControl!.tintColor = UIColor.whiteColor()
		
		self.tableView.registerNib(UINib(nibName: "JourneyTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "Journey")
		
		var image : UIImage! = UIImage(named: "BackGround")
		var imageView : UIImageView! = UIImageView(image: image)
		imageView.frame = UIScreen.mainScreen().bounds
		self.tableView.backgroundView = imageView
		self.tableView.separatorColor = UIColor(red: 145/255.0, green: 101/255.0, blue: 105/255.0, alpha: 1)
		
		// makes uirefreshcontrol visible..
		self.tableView.backgroundView!.layer.zPosition -= 1
		
		self.locationManager = CLLocationManager()
		self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
		self.locationManager.distanceFilter = kCLDistanceFilterNone
		self.locationManager.delegate = self
	}
	
	func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
		self.lastLocation = newLocation.coordinate
		
		if self.didUpdateDataAfterLocation == false {
			self.didUpdateDataAfterLocation = true
			
			self.refreshData(nil)
		}
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		mainNavigationDelegate.showNavigationBar()
		
		if iOS8 {
			self.locationManager.requestWhenInUseAuthorization()
		}
		
		self.locationManager.startUpdatingLocation()
		
		self.refreshData(nil)
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		self.isInSegue = false
		self.didAppear = true
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		
		if self.didAppear == false && self.isInSegue == true {
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
    
    func presentSetting() {
        self.performSegueWithIdentifier("goSetting", sender: nil)
    }
	
	func refreshData (sender: AnyObject?) {
		var callback: (err: NSError?, data: [Journey]) -> Void = { (err: NSError?, data: [Journey]) -> Void in
			self.journeys = data
			self.refreshControl!.endRefreshing()
			self.tableView.reloadData()
		}
		
		if self.lastLocation != nil || self.searchAttributes != nil {
			var attrs: NSString!
			if self.lastLocation != nil {
				attrs = NSString(format: "lat=%f&lng=%f%@%@", self.lastLocation!.latitude, self.lastLocation!.longitude, self.searchAttributes != nil ? "&" : "", self.searchAttributes != nil ? self.searchAttributes! : "")
			} else {
				attrs = self.searchAttributes!
			}
			
			// override if start|end location exists
			if self.searchProperties != nil && (self.searchProperties!.startLocation != nil || self.searchProperties!.endLocation != nil) {
				attrs = self.searchAttributes!
			}
			
			Journey.getAllByAttributes(attrs, callback: callback)
		} else {
			Journey.getAll(callback)
		}
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
		
		SVProgressHUD.showProgress(0, status: "Loading Message..", maskType: SVProgressHUDMaskType.Black)
		
		findMessageList(journey.owner!, { (list: MessageList?) -> Void in
			self.performSegueWithIdentifier("openMessages", sender: list)
		})
	}
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if cell.respondsToSelector(Selector("setSeparatorInset:")) {
            cell.separatorInset = UIEdgeInsetsZero
        }
        if cell.respondsToSelector(Selector("setLayoutMargins:")) {
            cell.layoutMargins = UIEdgeInsetsZero
        }
    }
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		SVProgressHUD.dismiss()
		isInSegue = true
		mainNavigationDelegate.hideNavigationBar()
		
		if segue.identifier == "openMessages" {
			var vc: MessagesViewController = segue.destinationViewController as MessagesViewController
			vc.list = sender as MessageList
		} else if segue.identifier == "searchProperties" {
			var vc: FSSearchPropertiesTableViewController = segue.destinationViewController as FSSearchPropertiesTableViewController
			vc.delegate = self
			
			if self.searchProperties != nil {
				vc.properties = self.searchProperties!
			}
		}
	}
	
	func pageRootTitle() -> NSString? {
		return "Close Fares"
	}
	
	func openMessageNotification(listId: NSString) {
		SVProgressHUD.showProgress(0, status: "Loading Message..", maskType: SVProgressHUDMaskType.Black)
		
		MessageList.getList(listId, callback: { (err: NSError?, data: MessageList?) -> Void in
			if data == nil {
				return
			}
			
			self.performSegueWithIdentifier("openMessages", sender: data!)
		})
	}
	
	func openJourneyNotification(reload: Bool, info: [NSString : AnyObject]) {
		
	}
	
	func didPressSearch() {
		self.performSegueWithIdentifier("searchProperties", sender: nil)
	}
	
	//MARK: FSSearchPropertiesDelegate
	
	func FSSearchPropertiesSetAssembledAttributes(properties: Journey?, attributes: NSString?) {
		self.searchProperties = properties
		self.searchAttributes = attributes
		
		// data is refreshed on ViewWillAppear..
	}
	
}


import UIKit
import MapKit

protocol LocationFinderDelegate {
	func didSelectLocation(location: LocationResult)
	
	func didClearLocation()
}

class LocationResult {
	var name: String = ""
	var location: CLLocationCoordinate2D
	
	init(name: String, location: CLLocationCoordinate2D) {
		self.name = name
		self.location = location
	}
	
	class func parse(res: [NSString: AnyObject]) -> LocationResult {
		var components = res["address_components"] as! [[NSString: AnyObject]]
		
		var preference = ["postal_town", "administrative_area_level_3", "locality", "administrative_area_level_2", "political"]
		
		var name: String = res["formatted_address"] as! String
		for pref in preference {
			var n = LocationResult.lookForComponentType(pref, components: components)
			if n != nil {
				name = n!
				break
			}
		}
		
		var geo = res["geometry"] as! [NSString: AnyObject]
		var location = geo["location"] as! [NSString: AnyObject]
		var lat = location["lat"] as! Double
		var lng = location["lng"] as! Double
		
		return LocationResult(name: name, location: CLLocationCoordinate2D(latitude: lat, longitude: lng))
	}
	
	class func lookForComponentType (type: NSString, components: [[NSString: AnyObject]]) -> String? {
		for component in components {
			var types = component["types"] as! [NSString]
			for t in types {
				if type.isEqualToString(t as String) {
					return component["short_name"] as? String
				}
			}
		}
		
		return nil
	}
	
	class func reduceDups (results: [LocationResult]) -> [LocationResult] {
		var res: [LocationResult] = []
		
		for (i, r) in enumerate(results) {
			var isDup = false
			
			for (x, dup) in enumerate(res) {
				if r.name == dup.name {
					isDup = true
					break
				}
			}
			
			if isDup {
				continue
			}
			
			res.append(r)
		}
		
		return res
	}
}

class LocationFinderTableViewController: UITableViewController, FSTextFieldCellProtocol {
	
	var cellTitle: String!
	var results: [LocationResult] = []
	
	var delegate: LocationFinderDelegate? = nil
	
	var locationManager: CLLocationManager!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.tableView.registerNib(UINib(nibName: "FSFullTextFieldTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "Field")
		
		self.navigationItem.hidesBackButton = true
		self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "dismissView:")
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Clear", style: UIBarButtonItemStyle.Plain, target: self, action: "clearLocation:")
		
		self.locationManager = CLLocationManager()
		self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
		self.locationManager.distanceFilter = kCLDistanceFilterNone
		
		if iOS8 {
			self.locationManager.requestWhenInUseAuthorization()
		}
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		
		self.locationManager.stopUpdatingLocation()
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		self.locationManager.startUpdatingLocation()
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		var cell: FSFullTextFieldTableViewCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! FSFullTextFieldTableViewCell
		cell.field.becomeFirstResponder()
	}
	
	func dismissView (sender: AnyObject?) {
		self.navigationController!.popViewControllerAnimated(true)
	}
	
	func clearLocation (sender: AnyObject?) {
		self.delegate!.didClearLocation()
		self.navigationController!.popViewControllerAnimated(true)
	}
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 2
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 0 {
			return 1
		}
		
		return results.count + 1
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		if indexPath.section == 0 {
			var cell: FSFullTextFieldTableViewCell? = tableView.dequeueReusableCellWithIdentifier("Field", forIndexPath: indexPath) as? FSFullTextFieldTableViewCell
			
			if cell == nil {
				cell = FSFullTextFieldTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Field")
			}
			
			cell!.field.autocapitalizationType = UITextAutocapitalizationType.Words
			cell!.field.placeholder = self.cellTitle
			cell!.delegate = self
			cell!.initialize()
			
			return cell!
		}
		
		var cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("basic", forIndexPath: indexPath) as! UITableViewCell
		
		cell.textLabel!.text = "My Location"
		
		if indexPath.row > 0 {
			var location = self.results[indexPath.row - 1]
			
			cell.textLabel!.text = location.name
		}
		
		return cell
	}
	
	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if section == 1 {
			return "Results"
		}
		
		return nil
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		if self.delegate == nil || indexPath.section == 0 {
			return
		}
		
		if indexPath.row == 0 {
			// find my location
			SVProgressHUD.showProgress(1.0, status: "Geolocating...", maskType: SVProgressHUDMaskType.Black)
			
			if self.locationManager!.location == nil {
				tableView.deselectRowAtIndexPath(indexPath, animated: true)
				return SVProgressHUD.showErrorWithStatus("Could not geolocate.")
			}
			
			var coord = self.locationManager.location.coordinate
			geocodeLocation(coord, { (err: NSError?, data: [[NSString: AnyObject]]) -> Void in
				if err != nil || data.count == 0 {
					tableView.deselectRowAtIndexPath(indexPath, animated: true)
					SVProgressHUD.showErrorWithStatus("Could not geolocate.")
					return
				}
				
				SVProgressHUD.dismiss()
				
//				var formatted = data[0]["formatted_address"] as String
				self.navigationController!.popViewControllerAnimated(true)
				self.delegate!.didSelectLocation(LocationResult.parse(data[0]))
			})
			
			return
		}
		
		var location = self.results[indexPath.row - 1]
		
		self.navigationController!.popViewControllerAnimated(true)
		self.delegate!.didSelectLocation(location)
	}
	
	func FSTextFieldCellValueChanged(cell: FSTextFieldTableViewCell?, value: NSString?) {
		geocodeAddress((self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! FSFullTextFieldTableViewCell).field.text, { (err: NSError?, data: [[NSString: AnyObject]]) -> Void in
			self.results = []
			for d in data {
				self.results.append(LocationResult.parse(d))
			}
			
			self.results = LocationResult.reduceDups(self.results)
			
			self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: UITableViewRowAnimation.Automatic)
		})
	}
	
	func FSTextFieldCellEditingBegan(cell: FSTextFieldTableViewCell?) {
	}
	
}

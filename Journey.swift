
import Foundation
import MapKit

class Journey {
	var _id: NSString? = nil
	
	var owner: String? = "" //_id
	var ownerObj: User? = nil
	
	var car: String? = "" //_id
	var isDriver: Bool = true
	var availableSeats: Int? = 0
	
	var startDate: NSDate? = NSDate()
	var startDateHuman: NSString? = ""
	var startLocation: NSString? = ""
	var startLat: Double? = 0
	var startLng: Double? = 0
	
	var endLocation: NSString? = ""
	var endLat: Double? = 0
	var endLng: Double? = 0
	
	var price: Float = 10.00
	
	init(){
	}
	
	init(_response: [NSString: AnyObject]) {
		self._id = _response["_id"] as? String
		
		self.owner = _response["owner"] as? String
		
		var _ownerObj: [NSString: AnyObject]? = _response["owner"] as? [NSString: AnyObject]
		if _ownerObj != nil {
			self.ownerObj = User(_response: _ownerObj!)
			self.owner = self.ownerObj!._id
		}
		
		self.car = _response["car"] as? String
		var isDriver = _response["isDriver"] as? Bool
		if isDriver != nil {
			self.isDriver = isDriver!
		}
		self.availableSeats = _response["availableSeats"] as? Int
		
		var start = _response["start"] as [String: AnyObject]
		
		// StartDate is not Double Type.  ->  Server Time     exam) 2014-11-26T10:21:09.064Z
		// Start Date Parsing Fixed. (Korea Develope Team Added.)
		var startStr = start["date"] as? String
		if startStr != nil {
			var dateFormatter = NSDateFormatter()
			var timeZone = NSTimeZone(name: "UTC")              // Server TimeZone
			dateFormatter.timeZone = timeZone
			dateFormatter.dateFormat = kISODateFormat
			
			self.startDate = dateFormatter.dateFromString(startStr!)
		}
		////////////////////////////////////////////////////////////////////////////////////
		
		self.startDateHuman = start["human"] as? String
		self.startLocation = start["location"] as? String
		var loc = start["loc"] as? [Double]
		if loc != nil && loc!.count == 2 {
			self.startLat = loc![0]
			self.startLng = loc![1]
		}
		
		var end = _response["end"] as [String: AnyObject]
		
		self.endLocation = end["location"] as? String
		loc = end["loc"] as? [Double]
		if loc != nil && loc!.count == 2 {
			self.endLat = loc![0]
			self.endLng = loc![1]
		}
		
		var price = _response["price"] as? Float
		if price != nil {
			self.price = price!
		}
	}
	
	func json() -> [NSObject: AnyObject] {
		var json: [NSObject: AnyObject] = [:]
		var startJson: [NSObject: AnyObject] = [:]
		var endJson: [NSObject: AnyObject] = [:]
		
		if self._id != nil { json["_id"] = self._id }
		
		if self.owner != nil { json["owner"] = self.owner }
		if self.car != nil { json["car"] = self.car }
		json["isDriver"] = self.isDriver
		if self.availableSeats != nil { json["availableSeats"] = self.availableSeats }
		
		if self.startDate != nil { startJson["date"] = self.startDate!.timeIntervalSince1970 }
		if self.startDateHuman != nil { startJson["human"] = self.startDateHuman }
		if self.startLocation != nil { startJson["location"] = self.startLocation }
		if self.startLat != nil && self.startLng != nil {
			startJson["loc"] = [self.startLng!, self.startLat!] as [Double]
		}
		json["start"] = startJson
		
		if self.endLocation != nil { endJson["location"] = self.endLocation }
		if self.endLat != nil && self.endLng != nil {
			endJson["loc"] = [self.endLng!, self.endLat!] as [Double]
		}
		json["end"] = endJson
		
		json["price"] = self.price
		
		return json
	}
	
	func getOwner (callback: () -> Void) {
		doRequest(makeRequest("/user/" + self.owner!, "GET"), { (err: NSError?, data: AnyObject?) -> Void in
			let json: [NSString: AnyObject]? = data as? [NSString: AnyObject]
			if json != nil {
				self.ownerObj = User(_response: json!)
			}
			
			callback()
		}, nil)
	}
	
	class func getAll (callback: (err: NSError?, data: [Journey]) -> Void) {
		getJourneys("/journeys", method: "GET", callback: callback)
	}
	
	class func getAllByAttributes (attributes: NSString, callback: (err: NSError?, data: [Journey]) -> Void) {
		getJourneys(NSString(format: "/journeys?%@", attributes), method: "GET", callback: callback)
	}
	
	class func getMyJourneys (callback: (err: NSError?, data: [Journey]) -> Void) {
		getJourneys("/journeys/my", method: "GET", callback: callback)
	}
	
	class func getUserJourneys (user: User, callback: (err: NSError?, data: [Journey]) -> Void) {
		getJourneys("/journeys/user/" + user._id!, method: "GET", callback: callback)
	}
	
	class func getJourneys(url: NSString, method: NSString, callback: (err: NSError?, data: [Journey]) -> Void) {
		doRequest(makeRequest(url, method), { (err: NSError?, data: AnyObject?) -> Void in
			var cars: [Journey] = []
			
			if data != nil {
				var dataObj = data as [[String: AnyObject]]
				
				for d in dataObj {
					cars.append(Journey(_response: d))
				}
			}
			
			callback(err: err, data: cars)
		}, nil)
	}
	
	func requestJoin (callback: (err: NSError?) -> Void) {
		doRequest(makeRequest("/journey/" + self._id!, "PUT"), { (err: NSError?, data: AnyObject?) -> Void in
			callback(err: err)
		}, nil)
	}
	
	func update (callback: (err: NSError?, data: AnyObject?) -> Void) {
		var request: NSMutableURLRequest
		
		if self._id == nil || self._id?.length == 0 {
			request = makeRequest("/journeys", "POST")
		} else {
			request = makeRequest("/journey/" + self._id!, "POST")
		}
		
		doPostRequest(request, callback, self.json())
	}
	
	func delete (callback: (err: NSError?, data: AnyObject?) -> Void) {
		if self._id == nil {
			callback(err: nil, data: nil)
			return
		}
		
		doRequest(makeRequest("/journey/" + self._id!, "DELETE"), callback, nil)
	}
	
	func getPassengers (callback: (err: NSError?, data: [JourneyPassenger]) -> Void) {
		doRequest(makeRequest("/journey/" + self._id! + "/passengers", "GET"), { (err: NSError?, data: AnyObject?) -> Void in
			if err != nil {
				callback(err: err, data: [])
				return
			}
			
			var passengers: [JourneyPassenger] = []
			let json: [[NSString: AnyObject]]? = data as? [[NSString: AnyObject]]
			if json != nil {
				for j in json! {
					passengers.append(JourneyPassenger(_response: j))
				}
			}
			
			callback(err: nil, data: passengers)
		}, nil)
	}
	
	func searchAttributes () -> NSString {
		var attrs: [NSString] = []
		
		if self.startLocation != nil && self.startLocation!.length > 0 {
			attrs.append(NSString(format: "startLocation=%@", startLocation!))
		}
		if self.endLocation != nil && self.endLocation!.length > 0 {
			attrs.append(NSString(format: "endLocation=%@", endLocation!))
		}
		if self.startDate != nil {
			attrs.append("startDate=" + String(Int(startDate!.timeIntervalSince1970) * 1000))
		}
		
		var attrString = ""
		for attr in attrs {
			attrString = attrString + "&" + attr
		}
		
		return attrString
	}
	
}

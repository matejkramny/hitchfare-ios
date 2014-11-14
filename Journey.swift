
import Foundation

class Journey {
	var _id: NSString? = nil
	var name: String? = ""
	
	var owner: String? = "" //_id
	var car: String? = "" //_id
	var isDriver: Bool = true
	var availableSeats: Int? = 0
	
	var startDate: NSDate? = NSDate()
	var startDateHuman: NSString? = ""
	var startLocation: NSString? = ""
	var startLat: Double? = 0
	var startLng: Double? = 0
	
	var endDate: NSDate? = NSDate()
	var endDateHuman: NSString? = ""
	var endLocation: NSString? = ""
	var endLat: Double? = 0
	var endLng: Double? = 0
	
	var price: Float = 10.00
	
	init(){
	}
	
	init(_response: [NSString: AnyObject]) {
		self.name = _response["name"] as? String
		
		self.owner = _response["owner"] as? String
		self.car = _response["car"] as? String
		var isDriver = _response["isDriver"] as? Bool
		if isDriver != nil {
			self.isDriver = isDriver!
		}
		self.availableSeats = _response["availableSeats"] as? Int
		
		var start = _response["start"] as [String: AnyObject]
		var startDate = start["date"] as? Double
		if startDate != nil {
			self.startDate = NSDate(timeIntervalSince1970: startDate!)
		}
		
		self.startDateHuman = start["human"] as? String
		self.startLocation = start["location"] as? String
		self.startLat = start["lat"] as? Double
		self.startLng = start["lng"] as? Double
		
		var end = _response["end"] as [String: AnyObject]
		var endDate = start["date"] as? Double
		if endDate != nil {
			self.endDate = NSDate(timeIntervalSince1970: startDate!)
		}
		
		self.endDateHuman = end["human"] as? String
		self.endLocation = end["location"] as? String
		self.endLat = end["lat"] as? Double
		self.endLng = end["lng"] as? Double
		
		var price = end["price"] as? Float
		if price != nil {
			self.price = price!
		}
	}
	
	func json() -> [NSObject: AnyObject] {
		var json: [NSObject: AnyObject] = [:]
		var startJson: [NSObject: AnyObject] = [:]
		var endJson: [NSObject: AnyObject] = [:]
		
		if self._id != nil { json["_id"] = self._id }
		if self.name != nil { json["name"] = self.name }
		
		if self.owner != nil { json["owner"] = self.owner }
		if self.car != nil { json["car"] = self.car }
		json["isDriver"] = self.isDriver
		if self.availableSeats != nil { json["availableSeats"] = self.availableSeats }
		
		if self.startDate != nil { startJson["date"] = self.startDate!.timeIntervalSince1970 }
		if self.startDateHuman != nil { startJson["human"] = self.startDateHuman }
		if self.startLocation != nil { startJson["location"] = self.startLocation }
		if self.startLat != nil { startJson["startLat"] = self.startLat }
		if self.startLng != nil { startJson["startLng"] = self.startLng }
		json["start"] = startJson
		
		if self.endDate != nil { endJson["date"] = self.endDate!.timeIntervalSince1970 }
		if self.endDateHuman != nil { endJson["human"] = self.endDateHuman }
		if self.endLocation != nil { endJson["location"] = self.endLocation }
		if self.endLat != nil { endJson["startLat"] = self.endLat }
		if self.endLng != nil { endJson["startLng"] = self.endLng }
		json["end"] = endJson
		
		json["price"] = self.price
		
		return json
	}
	
	class func getAll (callback: (err: NSError?, data: [Journey]) -> Void) {
		getJourneys("/journeys", method: "GET", callback: callback)
	}
	
	class func getMyJourneys (callback: (err: NSError?, data: [Journey]) -> Void) {
		getJourneys("/journeys/my", method: "GET", callback: callback)
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
	
	func update (callback: (err: NSError?, data: AnyObject?) -> Void) {
		var request: NSMutableURLRequest
		
		if self._id == nil || self._id?.length == 0 {
			request = makeRequest("/journeys", "POST")
		} else {
			request = makeRequest("/journey/" + self._id!, "PUT")
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
}

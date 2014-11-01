
import Foundation

class Journey {
	var _id: NSString? = nil
	var name: String? = ""
	
	var owner: String? = "" //_id
	var car: String? = "" //_id
	var driver: String? = "" //_id
	var availableSeats: Int? = 0
	
	var startDate: NSDate? = NSDate()
	var startDateHuman: NSString? = ""
	var startLat: Double? = 0
	var startLng: Double? = 0
	
	var endDate: NSDate? = NSDate()
	var endDateHuman: NSString? = ""
	var endLat: Double? = 0
	var endLng: Double? = 0
	
	var price: Double? = 0
	
	init(){}
	
	init(_response: [NSString: AnyObject]) {
		self.name = _response["name"] as? String
		
		self.owner = _response["owner"] as? String
		self.car = _response["car"] as? String
		self.driver = _response["driver"] as? String
		self.availableSeats = _response["availableSeats"] as? Int
		
		var start = _response["start"] as [String: AnyObject]
		var startDate = start["date"] as? Double
		if startDate != nil {
			self.startDate = NSDate(timeIntervalSince1970: startDate!)
		}
		
		self.startDateHuman = start["human"] as? String
		self.startLat = start["lat"] as? Double
		self.startLng = start["lng"] as? Double
		
		var end = _response["end"] as [String: AnyObject]
		var endDate = start["date"] as? Double
		if endDate != nil {
			self.endDate = NSDate(timeIntervalSince1970: startDate!)
		}
		
		self.endDateHuman = end["human"] as? String
		self.endLat = end["lat"] as? Double
		self.endLng = end["lng"] as? Double
		
		self.price = end["price"] as? Double
	}
	
	func json() -> [NSObject: AnyObject] {
		var json: [NSObject: AnyObject] = [:]
		var startJson: [NSObject: AnyObject] = [:]
		var endJson: [NSObject: AnyObject] = [:]
		
		if self._id != nil { json["_id"] = self._id }
		if self.name != nil { json["name"] = self.name }
		
		if self.owner != nil { json["owner"] = self.owner }
		if self.car != nil { json["car"] = self.car }
		if self.driver != nil { json["driver"] = self.driver }
		if self.availableSeats != nil { json["availableSeats"] = self.availableSeats }
		
		if self.startDate != nil { startJson["date"] = self.startDate!.timeIntervalSince1970 }
		if self.startDateHuman != nil { startJson["human"] = self.startDateHuman }
		if self.startLat != nil { startJson["startLat"] = self.startLat }
		if self.startLng != nil { startJson["startLng"] = self.startLng }
		json["start"] = startJson
		
		if self.endDate != nil { endJson["date"] = self.endDate!.timeIntervalSince1970 }
		if self.endDateHuman != nil { endJson["human"] = self.endDateHuman }
		if self.endLat != nil { endJson["startLat"] = self.endLat }
		if self.endLng != nil { endJson["startLng"] = self.endLng }
		json["end"] = endJson
		
		if self.price != nil { json["price"] = self.price }
		
		return json
	}
	
	class func getAll (callback: (err: NSError?, data: [Journey]) -> Void) {
		doRequest(makeRequest("/journeys", "GET"), { (err: NSError?, data: AnyObject?) -> Void in
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
		
		doRequest(request, callback, nil)
	}
	
	func delete (callback: (err: NSError?, data: AnyObject?) -> Void) {
		if self._id == nil {
			callback(err: nil, data: nil)
			return
		}
		
		doRequest(makeRequest("/journey/" + self._id!, "DELETE"), callback, nil)
	}
}

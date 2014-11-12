
import Foundation

class Car: NSObject {
	var _id: NSString? = nil
	var name: NSString = ""
	var owner: User? = nil
	var seats: Int = 0
	
	override init() {
		super.init()
	}
	
	init(_response: [NSString: AnyObject]) {
		self._id = _response["_id"] as? String
		self.seats = _response["seats"] as Int
		self.name = _response["name"] as String
	}
	
	func json() -> [NSObject: AnyObject] {
		var json: [NSObject: AnyObject] = [:]
		
		if self._id != nil { json["_id"] = self._id }
		json["name"] = self.name
		json["seats"] = self.seats
		
		if self.owner != nil { json["owner"] = self.owner!._id }
		
		return json
	}
	
	class func getAll (callback: (err: NSError?, data: [Car]) -> Void) {
		doRequest(makeRequest("/cars", "GET"), { (err: NSError?, data: AnyObject?) -> Void in
			var cars: [Car] = []
			
			if data != nil {
				var dataObj = data as [[String: AnyObject]]
				
				for d in dataObj {
					cars.append(Car(_response: d))
				}
			}
			
			callback(err: err, data: cars)
		}, nil)
	}
	
	func update (callback: (err: NSError?, data: AnyObject?) -> Void) {
		var request: NSMutableURLRequest
		
		if self._id == nil || self._id?.length == 0 {
			request = makeRequest("/cars", "POST")
		} else {
			request = makeRequest("/car/" + self._id!, "PUT")
		}
		
		doPostRequest(request, callback, self.json())
	}
	
	func remove (callback: (err: NSError?, data: AnyObject?) -> Void) {
		if self._id == nil {
			callback(err: nil, data: nil)
			return
		}
		
		doRequest(makeRequest("/car/" + self._id!, "DELETE"), callback, nil)
	}
}

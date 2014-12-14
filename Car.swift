
import Foundation

class Car: NSObject {
	var _id: NSString? = nil
	
	var picture: NSString? = nil
	var owner: User? = nil
	var name: NSString = ""
	var carDescription: NSString = ""
	
	var seats: Int = 0
	
	override init() {
		super.init()
	}
	
	init(_response: [NSString: AnyObject]) {
		self._id = _response["_id"] as? String
		self.seats = _response["seats"] as Int
		self.name = _response["name"] as String
		var desc = _response["description"] as? String
		if desc != nil {
			self.carDescription = desc!
		}
		
		self.picture = _response["url"] as? String
	}
	
	func json() -> [NSObject: AnyObject] {
		var json: [NSObject: AnyObject] = [:]
		
		if self._id != nil { json["_id"] = self._id }
		json["name"] = self.name
		json["seats"] = self.seats
		json["description"] = self.carDescription
		
		if self.owner != nil { json["owner"] = self.owner!._id }
		
		return json
	}
	
	class func getAll (user: User, callback: (err: NSError?, data: [Car]) -> Void) {
		var url = "/user/" + user._id! + "/cars"
		if user === currentUser! {
			url = "/cars"
		}
		
		doRequest(makeRequest(url, "GET"), { (err: NSError?, data: AnyObject?) -> Void in
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
	
	func update (withImage: UIImage?, callback: (err: NSError?, data: AnyObject?) -> Void) {
		var request: NSMutableURLRequest
		
		if self._id == nil || self._id?.length == 0 {
			request = makeRequest("/cars", "POST")
		} else {
			request = makeRequest("/car/" + self._id!, "PUT")
		}
		
		doPostRequest(request, { (err: NSError?, data: AnyObject?) -> Void in
			if err != nil {
				callback(err: err, data: data)
				return
			}
			
			var d: [NSString: AnyObject]? = data as? [NSString: AnyObject]
			if data != nil {
				self._id = d!["_id"] as? NSString
			}
			
			if withImage != nil {
				self.uploadImage(withImage!, callback)
				return
			}
			
			callback(err: err, data: data)
		}, self.json())
	}
	
	func uploadImage (image: UIImage, callback: (err: NSError?, data: AnyObject?) -> Void) {
		var request = makeRequest("/car/" + self._id! + "/image", "PUT")
		
		let imageData: NSData = UIImagePNGRepresentation(image)
		
		let boundary = "94414664728899466413890873741"
		request.setValue("multipart/form-data; boundary=" + boundary, forHTTPHeaderField: "Content-Type")
		
		var data: NSMutableData = NSMutableData()
		
		var bodyContent = NSMutableString()
		bodyContent.appendFormat("\r\n--%@\r\n", boundary)
		bodyContent.appendString("Content-Disposition: form-data; name=\"picture\"; filename=\"image.jpeg\"\r\n")
		bodyContent.appendString("Content-Type: application/octet-stream\r\n")
		bodyContent.appendString("Content-Transfer-Encoding: binary\r\n")
		bodyContent.appendFormat("Content-Length: %i\r\n\r\n", imageData.length)
		
		data.appendData(bodyContent.dataUsingEncoding(NSASCIIStringEncoding)!)
		data.appendData(imageData)
		data.appendData(NSString(string: "\r\n--" + boundary + "--\r\n").dataUsingEncoding(NSASCIIStringEncoding)!)
		
		doRequest(request, callback, data)
	}
	
	func remove (callback: (err: NSError?, data: AnyObject?) -> Void) {
		if self._id == nil {
			callback(err: nil, data: nil)
			return
		}
		
		doRequest(makeRequest("/car/" + self._id!, "DELETE"), callback, nil)
	}
}

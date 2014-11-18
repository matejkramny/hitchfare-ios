
import Foundation

class UserPicture {
	var isSilhouette: Bool = false
	var url: NSString? = nil
	var width: NSString? = nil
	var height: NSString? = nil
}

class User {
	var _id: NSString? = nil
	var email: NSString? = nil
	var first_name: NSString? = nil
	var id: NSString? = nil
	var last_name: NSString? = nil
	var name: NSString? = nil
	var picture: UserPicture? = nil
	
	init(){}
	
	init(_response: [NSString: AnyObject]) {
		self.parse(_response)
	}
	
	func parse (_response: [NSString: AnyObject]) {
		var pictureData: [String: AnyObject] = _response["picture"] as [String: AnyObject]
		if pictureData["url"] == nil {
			pictureData = pictureData["data"] as [String: AnyObject]
		}
		
		self.picture = UserPicture()
		
		var isSilhouette = pictureData["is_silhouette"] as? Bool
		self.picture!.isSilhouette = isSilhouette != nil && isSilhouette! == true
		self.picture!.url = pictureData["url"] as String?
		
		self._id = _response["_id"] as String?
		self.email = _response["email"] as String?
		self.first_name = _response["first_name"] as String?
		self.id = _response["id"] as String?
		self.last_name = _response["last_name"] as String?
		self.name = _response["name"] as String?
	}
	
	func register (completion: (error: NSError?, data: AnyObject?) -> Void) {
		var request = makeRequest("/register", "POST")
		doPostRequest(request, { (err: NSError?, data: AnyObject?) -> Void in
			var error = err;
			queueRequests = false
			
			doRequest(makeRequest("/me", "GET"), { (err: NSError?, data: AnyObject?) -> Void in
				if data != nil {
					var json: [NSString: AnyObject] = data as [NSString: AnyObject]
					self.parse(json)
				}
				
				queueRequests = false
				completion(error: error, data: data)
			}, nil)
			
			queueRequests = true
		}, self.json())
	}
	
	class func find(_id: NSString, callback: (user: User?) -> Void) {
		doRequest(makeRequest("/user/"+_id, nil), { (err: NSError?, data: AnyObject?) -> Void in
			var json: [NSString: AnyObject] = data as [NSString: AnyObject]
			var user = User(_response: json)
			callback(user: user)
		}, nil)
	}
	
	func json() -> [NSObject: AnyObject] {
		var json: [NSObject: AnyObject] = [:]
		
		if self.email != nil { json["email"] = email! }
		if self.first_name != nil { json["first_name"] = first_name! }
		if self.id != nil { json["id"] = id! }
		if self.last_name != nil { json["last_name"] = last_name! }
		if self.name != nil { json["name"] = name! }
		if self.picture != nil { json["picture"] = ["url": self.picture!.url!, "is_silhouette": self.picture!.isSilhouette] as AnyObject }
		
		return json
	}
}

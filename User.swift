
import Foundation

class UserPicture {
	var isSilhouette: Bool = false
	var url: NSString!
	var width: NSString? = nil
	var height: NSString? = nil
	
	init(url: NSString) {
		self.url = url
	}
}

class User {
	var _id: NSString? = nil
	var email: NSString? = nil
	var first_name: NSString? = nil
	var id: NSString? = nil
	var last_name: NSString? = nil
	var name: NSString? = nil
	var picture: UserPicture? = nil
	var userFriends: [NSString] = [] // [fbId]
	
	init(){}
	
	init(_response: [NSString: AnyObject]) {
		self.parse(_response)
	}
	
	func parse (_response: [NSString: AnyObject]) {
		var pictureData: [NSObject: AnyObject] = _response["picture"] as [String: AnyObject]
		var url: NSString? = pictureData["url"] as? NSString
		if url == nil {
			pictureData = pictureData["data"] as [String: AnyObject]
			url = pictureData["url"] as? NSString
		}
		
		self.picture = UserPicture(url: url!)
		
		var isSilhouette = pictureData["is_silhouette"] as? Bool
		self.picture!.isSilhouette = isSilhouette != nil && isSilhouette! == true
		
		self._id = _response["_id"] as String?
		self.email = _response["email"] as String?
		self.first_name = _response["first_name"] as String?
		self.id = _response["id"] as String?
		self.last_name = _response["last_name"] as String?
		self.name = _response["name"] as String?
		
		var friends: [NSString: AnyObject]? = _response["friends"] as? [NSString: AnyObject]
		if friends != nil {
			var friendsData: [[NSString: AnyObject]]? = friends!["data"] as? [[NSString: AnyObject]]
			if friendsData != nil {
				for fData: [NSString: AnyObject] in friendsData! {
					var id: NSString? = fData["id"] as? NSString
					self.userFriends.append(id!)
				}
			}
		}
		
		var userFriends: [NSString]? = _response["userFriends"] as? [NSString]
		if userFriends != nil {
			for uf in userFriends! {
				self.userFriends.append(uf)
			}
		}
	}
	
	func register (completion: (error: NSError?, data: AnyObject?) -> Void) {
		var request = makeRequest("/register", "POST")
		doPostRequest(request, { (err: NSError?, data: AnyObject?) -> Void in
			var error = err;
			queueRequests = false
			
			var _idJson: [NSString: AnyObject]? = data as? [NSString: AnyObject]
			if _idJson != nil {
				self._id = _idJson!["_id"] as? NSString
				saveSettings()
			}
			
			doRequest(makeRequest("/me", "GET"), { (err: NSError?, data: AnyObject?) -> Void in
				if data != nil {
					var json: [NSString: AnyObject] = data as [NSString: AnyObject]
					self.parse(json)
					saveSettings()
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
		
		if self._id != nil { json["_id"] = self._id! }
		if self.email != nil { json["email"] = self.email! }
		if self.first_name != nil { json["first_name"] = self.first_name! }
		if self.id != nil { json["id"] = self.id! }
		if self.last_name != nil { json["last_name"] = self.last_name! }
		if self.name != nil { json["name"] = self.name! }
		if self.picture != nil { json["picture"] = ["url": self.picture!.url!, "is_silhouette": self.picture!.isSilhouette] as AnyObject }
		json["userFriends"] = self.userFriends;
		
		return json
	}
	
	func averageRating(callback: (err: NSError?, rating: Double?) -> Void) {
		doRequest(makeRequest("/rating/user/" + self._id!, "GET"), { (err: NSError?, data: AnyObject?) -> Void in
			var json: [NSString: AnyObject]? = data as? [NSString: AnyObject]
			if json != nil {
				let average: Double? = json!["average"] as? Double
				return callback(err: err, rating: average)
			}
			
			callback(err: err, rating: nil)
		}, nil)
	}
	
	func getMutualFriends (user: User, callback: (err: NSError?, friends: [User]) -> Void) {
		doRequest(makeRequest("/user/" + user._id! + "/mutualFriends", "GET"), { (err: NSError?, data: AnyObject?) -> Void in
			if err != nil {
				return callback(err: err, friends: [])
			}
			
			var json: [[NSString: AnyObject]]? = data as? [[NSString: AnyObject]]
			var friends: [User] = []
			if json != nil {
				for u in json! {
					friends.append(User(_response: u))
				}
			}
			
			callback(err: nil, friends: friends)
		}, nil)
	}
}

//
//  User.swift
//  FareShout
//
//  Created by Matej Kramny on 27/10/2014.
//  Copyright (c) 2014 Matej Kramny. All rights reserved.
//

import Foundation

class UserPicture {
	var isSilhouette: Bool = false
	var url: NSString? = nil
	var width: NSString? = nil
	var height: NSString? = nil
}

class User {
	var email: NSString? = nil
	var first_name: NSString? = nil
	var id: NSString? = nil
	var last_name: NSString? = nil
	var name: NSString? = nil
	var picture: UserPicture? = nil
	
	init(_response: [NSString: AnyObject]) {
		var pictureData: [String: AnyObject] = _response["picture"] as [String: AnyObject]
		pictureData = pictureData["data"] as [String: AnyObject]
		
		self.picture = UserPicture()
		self.picture?.isSilhouette = pictureData["is_silhouette"] as Bool
		self.picture?.url = pictureData["url"] as String?
		
		self.email = _response["email"] as String?
		self.first_name = _response["first_name"] as String?
		self.id = _response["id"] as String?
		self.last_name = _response["last_name"] as String?
		self.name = _response["name"] as String?
	}
	
	func register (callback: (error: NSError?, data: AnyObject?) -> Void) {
		var request = makeRequest("/register", "POST")
		doPostRequest(request, callback, self.json())
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

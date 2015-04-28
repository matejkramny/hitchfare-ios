
class JourneyPassenger {
	var _id: NSString?
	
	var journey: Journey!
	var user: User!
	
	var approved: Bool = false
	var didApprove: Bool = false
	var approvedWhen: NSDate? = nil
	
	var rated: Bool = false
	var rating: Int = 0
	
	var requested: NSDate? = nil
	
	init(journey: Journey, user: User){
		self.journey = journey
		self.user = user
	}
	
	init(_response: [NSString: AnyObject]) {
		self._id = _response["_id"] as? NSString
		
		self.journey = Journey(_response: _response["journey"] as! [NSString: AnyObject])
		self.user = User(_response: _response["user"] as! [NSString: AnyObject])
		
		var approved = _response["approved"] as? Bool
		if approved != nil {
			self.approved = approved!
		}
		
		var didApprove = _response["didApprove"] as? Bool
		if didApprove != nil {
			self.didApprove = didApprove!
		}
		
		var approvedWhen = _response["approvedWhen"] as? Double
		if approvedWhen != nil {
			self.approvedWhen = NSDate(timeIntervalSince1970: approvedWhen! / 1000)
		}
		
		var rated = _response["rated"] as? Bool
		if rated != nil {
			self.rated = rated!
		}
		
		var rating = _response["rating"] as? Int
		if rating != nil {
			self.rating = rating!
		}
		
		var requested = _response["requested"] as? Double
		if requested != nil {
			self.requested = NSDate(timeIntervalSince1970: requested! / 1000)
		}
	}
	
	func json() -> [NSObject: AnyObject] {
		var json: [NSObject: AnyObject] = [:]
		
		if self._id != nil { json["_id"] = self._id }
		
		json["journey"] = self.journey._id!
		json["user"] = self.user._id!
		
		json["approved"] = self.approved
		json["didApprove"] = self.didApprove
		if self.approvedWhen != nil { json["approvedWhen"] = self.approvedWhen!.timeIntervalSince1970 }
		
		json["rated"] = self.rated
		json["rating"] = self.rating
		
		if self.requested != nil { json["requested"] = self.requested!.timeIntervalSince1970 }
		
		return json
	}
	
	class func getAllJourneyRequests (callback: (err: NSError?, data: [JourneyPassenger]) -> Void) {
		doRequest(makeRequest("/journeys/requests", "GET"), { (err: NSError?, data: AnyObject?) -> Void in
			var reqs: [JourneyPassenger] = []
			
			var json: [[NSString: AnyObject]]? = data as? [[NSString: AnyObject]]
			if json != nil {
				for obj in json! {
					reqs.append(JourneyPassenger(_response: obj))
				}
			}
			
			callback(err: err, data: reqs)
		}, nil)
	}
	
	class func getMyJourneyRequests (callback: (err: NSError?, data: [JourneyPassenger]) -> Void) {
		doRequest(makeRequest("/journeys/myrequests", "GET"), { (err: NSError?, data: AnyObject?) -> Void in
			var reqs: [JourneyPassenger] = []
			
			var json: [[NSString: AnyObject]]? = data as? [[NSString: AnyObject]]
			if json != nil {
				for obj in json! {
					reqs.append(JourneyPassenger(_response: obj))
				}
			}
			
			callback(err: err, data: reqs)
		}, nil)
	}
	
	class func getJourneyReviewRequests (callback: (err: NSError?, data: [JourneyPassenger]) -> Void) {
		doRequest(makeRequest("/journeys/reviewable", "GET"), { (err: NSError?, data: AnyObject?) -> Void in
			var reqs: [JourneyPassenger] = []
			
			var json: [[NSString: AnyObject]]? = data as? [[NSString: AnyObject]]
			if json != nil {
				for obj in json! {
					reqs.append(JourneyPassenger(_response: obj))
				}
			}
			
			callback(err: err, data: reqs)
		}, nil)
	}
	
	func reviewJourney (review: Int, callback: (err: NSError?) -> Void) {
		doRequest(makeRequest("/journey/" + (self.journey._id! as String) + "/request/" + (self._id as! String) + "/review/" + String(review), "PUT"), { (err: NSError?, data: AnyObject?) -> Void in
			callback(err: err)
		}, nil)
	}
	
	func approveRequest (callback: (err: NSError?) -> Void) {
		doRequest(makeRequest("/journey/" + (self.journey._id! as String) + "/request/" + (self._id! as String), "PUT"), { (err: NSError?, data: AnyObject?) -> Void in
			callback(err: err)
		}, nil)
	}
	
	func rejectRequest (callback: (err: NSError?) -> Void) {
		doRequest(makeRequest("/journey/" + (self.journey._id! as String) + "/request/" + (self._id! as String), "DELETE"), { (err: NSError?, data: AnyObject?) -> Void in
			callback(err: err)
		}, nil)
	}
	
}

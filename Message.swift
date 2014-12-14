
import Foundation

class Message {
	// Optional when creating a new message
	var _id: NSString? = nil
	
	var list: MessageList!
	var message: NSString!
	var sent: NSDate!
	var sender: NSString! // user _id!
	
	init(list: MessageList){
		self.list = list
	}
	
	init(_response: [NSString: AnyObject]) {
		self._id = _response["_id"] as? String
		
		self.message = _response["message"] as NSString
		var sent = _response["sent"] as? Double
		if sent != nil {
			self.sent = NSDate(timeIntervalSince1970: sent!)
		}
		self.sender = _response["sender"] as NSString
	}
	
	func sendMessage (callback: (err: NSError?, data: AnyObject?) -> Void) {
		doPostRequest(makeRequest("/message/" + self.list._id, "POST"), { (err: NSError?, data: AnyObject?) -> Void in
			callback(err: err, data: data)
			return
		}, self.json())
	}
	
	func json() -> [NSObject: AnyObject] {
		var json: [NSObject: AnyObject] = [:]
		
		if self.list != nil { json["list"] = list._id }
		if self.message != nil { json["message"] = message }
		if self.sent != nil { json["sent"] = sent.timeIntervalSince1970 * 1000 }
		if self.sender != nil { json["sender"] = sender }
		
		return json
	}
}

class MessageList {
	var _id: NSString!
	
	var sender: User!
	var receiver: User!
	var messages: [Message] = []
	var lastMessage: Message? = nil
	
	init(){}
	
	init(_response: [NSString: AnyObject]) {
		self._id = _response["_id"] as String
		
		var sender = _response["sender"] as? [NSString: AnyObject]
		if sender != nil {
			self.sender = User(_response: sender!)
		}
		
		var receiver = _response["receiver"] as? [NSString: AnyObject]
		if receiver != nil {
			self.receiver = User(_response: receiver!)
		}
		
		var lastMessage = _response["lastMessage"] as? [NSString: AnyObject]
		if lastMessage != nil {
			self.lastMessage = Message(_response: lastMessage!)
		}
	}
	
	class func getLists (callback: (err: NSError?, data: [MessageList]) -> Void) {
		doRequest(makeRequest("/messages", "GET"), { (err: NSError?, data: AnyObject?) -> Void in
			var lists: [MessageList] = []
			
			if data != nil {
				var dataObj = data as [[String: AnyObject]]
				
				for d in dataObj {
					lists.append(MessageList(_response: d))
				}
			}
			
			callback(err: err, data: lists)
		}, nil)
	}
	
	class func getList(_id: NSString, callback: (err: NSError?, data: MessageList?) -> Void) {
		doRequest(makeRequest("/messages/list/" + _id, "GET"), { (err: NSError?, data: AnyObject?) -> Void in
			var list: MessageList?
			
			if data != nil {
				var dataObj = data as [String: AnyObject]
				
				list = MessageList(_response: dataObj)
			}
			
			callback(err: err, data: list)
		}, nil)
	}
	
	class func createList (user_id: NSString, callback: (err: NSError?, data: MessageList?) -> Void) {
		doRequest(makeRequest("/messages/" + user_id, "PUT"), { (err: NSError?, data: AnyObject?) -> Void in
			var list: MessageList?
			
			if data != nil {
				var dataObj = data as [String: AnyObject]
				
				list = MessageList(_response: dataObj)
			}
			
			callback(err: err, data: list)
		}, nil)
	}
	
	func getMessages (callback: (err: NSError?, data: [Message]) -> Void) {
		doRequest(makeRequest("/messages/" + self._id, "GET"), { (err: NSError?, data: AnyObject?) -> Void in
			self.messages = []
			
			if data != nil {
				var dataObj = data as [[String: AnyObject]]
				
				for d in dataObj {
					self.messages.append(Message(_response: d))
				}
			}
			
			callback(err: err, data: self.messages)
		}, nil)
	}
	
	func deleteList (callback: (err: NSError?) -> Void) {
		doRequest(makeRequest("/message/" + self._id, "DELETE"), { (err: NSError?, data: AnyObject?) -> Void in
			if err != nil {
				return callback(err: err)
			}
			
			callback(err: nil)
		}, nil)
	}
	
	func json() -> [NSObject: AnyObject] {
		var json: [NSObject: AnyObject] = [:]
		
		if self.sender != nil { json["sender"] = sender._id }
		if self.receiver != nil { json["receiver"] = receiver._id }
		
		return json
	}
}


import Foundation

class SharedStorage: NSObject {
	var cars: [Car] = []
	var accessToken: NSString?
	
	override init() {
		super.init()
	}
	
	func getCars (user: User, callback: (err: NSError?) -> Void) {
		Car.getAll(user, { (err: NSError?, data: [Car]) -> Void in
			self.cars = data
			
			callback(err: err)
			
			return
		})
	}
	
	func findCarWithId (_id: NSString) -> Car? {
		for car: Car in cars {
			if car._id == _id {
				return car
			}
		}
		
		return nil
	}
}

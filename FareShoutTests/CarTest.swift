
import Foundation
import XCTest

class CarTests: XCTestCase {
	override func setUp() {
		super.setUp()
	}
	
	override func tearDown() {
		super.tearDown()
	}
	
	func testCar () {
		var expectation = self.expectationWithDescription("Get cars")
		
		Car.getAll({ (err: NSError?, data: [Car]) -> Void in
			println(data)
			XCTAssert(data.count == 1, "Data length")
			
			expectation.fulfill()
		})
	}
}

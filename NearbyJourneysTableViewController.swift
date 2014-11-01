
import UIKit

class NearbyJourneysTableViewCell: UITableViewController {
	override func viewDidLoad() {
		super.viewDidLoad()
		
		Journey.getAll({ (err: NSError?, data: [Journey]) -> Void in
			
		})
	}
}

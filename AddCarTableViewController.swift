
import UIKit

class AddCarTableViewController: UITableViewController {
	
	var car: Car! = Car()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.tableView.registerNib(UINib(nibName: "FSTextFieldTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "TextField")
		
		self.navigationItem.title = "Add Car"
		self.navigationItem.hidesBackButton = true
		self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "cancelAdd:")
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: "add:")
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as FSTextFieldTableViewCell
		cell.field.becomeFirstResponder()
	}
	
	func cancelAdd (sender: AnyObject) {
		self.navigationController?.popViewControllerAnimated(true)
	}
	
	func add (sender: AnyObject) {
		car.name = getCellContents(NSIndexPath(forRow: 0, inSection: 0))
		
		var s = getCellContents(NSIndexPath(forRow: 0, inSection: 1))
		var seats: Int? = s.integerValue
		if seats == nil || seats! == 0 {
			return
		}
		
		car.seats = seats!
		
		SVProgressHUD.showProgress(1.0, status: "Saving...", maskType: SVProgressHUDMaskType.Black)
		car.update({ (err: NSError?, data: AnyObject?) -> Void in
			SVProgressHUD.dismiss()
			
			self.navigationController!.popViewControllerAnimated(true)
			return
		})
	}
	
	func getCellContents(indexPath: NSIndexPath) -> NSString {
		return (self.tableView.cellForRowAtIndexPath(indexPath) as FSTextFieldTableViewCell).field.text
	}
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 2
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		var identifier = "TextField"
		
		let cell: FSTextFieldTableViewCell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as FSTextFieldTableViewCell
		
		cell.selectionStyle = UITableViewCellSelectionStyle.None
		
		switch indexPath.section {
		case 0:
			cell.label.text = "Name"
			cell.field.placeholder = "Car Name"
			
			break
		case 1:
			cell.label.text = "Number of Seats"
			cell.field.placeholder = "4"
			cell.field.keyboardType = UIKeyboardType.NumberPad
			
			break
		default:
			break
		}
		
		return cell
	}
	
	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 44
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		var cell: FSTextFieldTableViewCell = tableView.cellForRowAtIndexPath(indexPath) as FSTextFieldTableViewCell
		cell.field.becomeFirstResponder()
		
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}
	
}

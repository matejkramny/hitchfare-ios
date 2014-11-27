
import UIKit

class AddCarTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	
	var car: Car! = Car()
	var chosenImage: UIImage? = nil
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.tableView.registerNib(UINib(nibName: "FSTextFieldTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "TextField")
		self.tableView.registerNib(UINib(nibName: "ImageTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "ImageView")
		self.tableView.registerNib(UINib(nibName: "FSTextViewTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "TextView")
		
		self.navigationItem.title = "Add Car"
		self.navigationItem.hidesBackButton = true
		self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "cancelAdd:")
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: "add:")
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		let cell: FSTextFieldTableViewCell? = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as? FSTextFieldTableViewCell
		if cell == nil {
			return
		}
		
		cell!.field.becomeFirstResponder()
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
		
		car.carDescription = (self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as FSTextViewTableViewCell).textView.text
		car.seats = seats!
		
		SVProgressHUD.showProgress(1.0, status: "Saving...", maskType: SVProgressHUDMaskType.Black)
		car.update(chosenImage, callback: { (err: NSError?, data: AnyObject?) -> Void in
			SVProgressHUD.dismiss()
			
			self.navigationController!.popViewControllerAnimated(true)
			return
		})
	}
	
	func getCellContents(indexPath: NSIndexPath) -> NSString {
		return (self.tableView.cellForRowAtIndexPath(indexPath) as FSTextFieldTableViewCell).field.text
	}
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 3
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if chosenImage != nil && section == 2 || section == 0 {
			return 2
		}
		
		return 1
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		if indexPath.section == 2 {
			if indexPath.row == 0 {
				var cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("basic", forIndexPath: indexPath) as UITableViewCell
				
				cell.textLabel.text = "Select Picture"
				if chosenImage != nil {
					cell.textLabel.text = "Remove Picture"
				}
				
				return cell
			} else {
				var cell: ImageTableViewCell? = tableView.dequeueReusableCellWithIdentifier("ImageView", forIndexPath: indexPath) as? ImageTableViewCell
				
				if cell == nil {
					cell = ImageTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "ImageView")
				}
				
				cell!.customImageView.image = chosenImage
				
				return cell! as UITableViewCell
			}
		}
		
		if (indexPath.section == 0 && indexPath.row == 0) || indexPath.section == 1 {
			var identifier = "TextField"
			
			var cell: FSTextFieldTableViewCell? = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as? FSTextFieldTableViewCell
			
			if cell == nil {
				cell = FSTextFieldTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "TextField")
			}
			
			cell!.selectionStyle = UITableViewCellSelectionStyle.None
			
			switch indexPath.section {
			case 0:
				cell!.label.text = "Name"
				cell!.field.placeholder = "Car Name"
				cell!.field.keyboardType = UIKeyboardType.Default
				cell!.field.autocapitalizationType = UITextAutocapitalizationType.Words
				
				break
			case 1:
				cell!.label.text = "Number of Seats"
				cell!.field.placeholder = "4"
				cell!.field.keyboardType = UIKeyboardType.NumberPad
				
				break
			default:
				break
			}
			
			return cell!
		}
		
		if indexPath.section == 0 && indexPath.row == 1 {
			var cell: FSTextViewTableViewCell? = tableView.dequeueReusableCellWithIdentifier("TextView", forIndexPath: indexPath) as? FSTextViewTableViewCell
			
			if cell == nil {
				cell = FSTextViewTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "TextView")
			}
			
			cell!.fieldTitle.text = "Description"
			cell!.textView.text = car.carDescription
			
			cell!.textView.layer.borderColor = UIColor.grayColor().colorWithAlphaComponent(0.2).CGColor
			cell!.textView.layer.borderWidth = 1
			cell!.textView.layer.cornerRadius = 5
			cell!.textView.clipsToBounds = true
			
			return cell! as UITableViewCell
		}
		
		return UITableViewCell()
	}
	
	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		if indexPath.section == 2 && indexPath.row == 1 {
			var aspectRatio = chosenImage!.size.height / chosenImage!.size.width
			
			return self.tableView.frame.size.width * aspectRatio
		}
		
		if indexPath.section == 0 && indexPath.row == 1 {
			return 44 * 3
		}
		
		return 44
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		if indexPath.section == 2 {
			if indexPath.row != 0 {
				return
			}
			
			// Pick/remove image
			self.selectOrRemoveImage()
			
			return
		}
		
		if indexPath.section == 0 && indexPath.row == 1 {
			var cell: FSTextViewTableViewCell = tableView.cellForRowAtIndexPath(indexPath) as FSTextViewTableViewCell
			cell.textView.becomeFirstResponder()
			
			tableView.deselectRowAtIndexPath(indexPath, animated: true)
			
			return
		}
		
		var cell: FSTextFieldTableViewCell = tableView.cellForRowAtIndexPath(indexPath) as FSTextFieldTableViewCell
		cell.field.becomeFirstResponder()
		
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}
	
	func selectOrRemoveImage () {
		if chosenImage != nil {
			chosenImage = nil
			self.tableView.reloadSections(NSIndexSet(index: 2), withRowAnimation: UITableViewRowAnimation.Fade)
			
			return
		}
		
		if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
			return
		}
		
		var imag = UIImagePickerController()
		imag.delegate = self
		imag.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
		imag.allowsEditing = false
		self.presentViewController(imag, animated: true, completion: nil)
	}
	
	func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
		self.chosenImage = image
		self.tableView.reloadSections(NSIndexSet(index: 2), withRowAnimation: UITableViewRowAnimation.Fade)
		self.dismissViewControllerAnimated(true, completion: nil)
	}
	
}


import UIKit

class AddCarTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, StepperCellDelegate, FSTextFieldCellProtocol, UITextViewDelegate {
	
	var car: Car! = Car()
	var chosenImage: UIImage? = nil
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.tableView.registerNib(UINib(nibName: "FSTextFieldTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "TextField")
		self.tableView.registerNib(UINib(nibName: "ImageTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "ImageView")
		self.tableView.registerNib(UINib(nibName: "FSTextViewTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "TextView")
		self.tableView.registerNib(UINib(nibName: "StepperTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "Stepper")
		
		self.navigationItem.title = "Add Car"
		if self.car._id != nil {
			self.navigationItem.title = "Edit Car"
		}
		
		self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
		
		self.navigationItem.hidesBackButton = true
		self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "cancelAdd:")
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: "add:")
		
		var image : UIImage! = UIImage(named: "BackGround")
		var imageView : UIImageView! = UIImageView(image: image)
		imageView.frame = UIScreen.mainScreen().bounds
		self.tableView.backgroundView = imageView
		self.tableView.separatorColor = UIColor(red: 145/255.0, green: 101/255.0, blue: 105/255.0, alpha: 1)
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
		SVProgressHUD.showProgress(1.0, status: "Saving...", maskType: SVProgressHUDMaskType.Black)
		car.update(chosenImage, callback: { (err: NSError?, data: AnyObject?) -> Void in
			SVProgressHUD.dismiss()
			
			self.navigationController!.popViewControllerAnimated(true)
			return
		})
	}
	
	func getCellContents(indexPath: NSIndexPath) -> NSString {
        if indexPath.section == 1 {
            return String(format: "%.0f", (self.tableView.cellForRowAtIndexPath(indexPath) as StepperTableViewCell).stepper.value)
        }
        
		return (self.tableView.cellForRowAtIndexPath(indexPath) as FSTextFieldTableViewCell).field.text
	}
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return self.car._id == nil ? 3 : 4
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
				
				cell.textLabel!.text = "Select Picture"
				if chosenImage != nil {
					cell.textLabel!.text = "Remove Picture"
				}
				
				cell.backgroundColor = UIColor.clearColor()
				cell.textLabel!.textColor = UIColor.whiteColor()
				
				return cell
			} else {
				var cell: ImageTableViewCell? = tableView.dequeueReusableCellWithIdentifier("ImageView", forIndexPath: indexPath) as? ImageTableViewCell
				
				if cell == nil {
					cell = ImageTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "ImageView")
				}
				
				cell!.customImageView.image = chosenImage
				
				return cell! as UITableViewCell
			}
		} else if indexPath.section == 3 {
			var cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("basic", forIndexPath: indexPath) as UITableViewCell
			
			cell.textLabel!.text = "Delete Car"
			cell.textLabel!.textColor = UIColor.redColor()
			
			return cell
		}
		
		if (indexPath.section == 0 && indexPath.row == 0) {
			var identifier = "TextField"
			
			var cell: FSTextFieldTableViewCell? = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as? FSTextFieldTableViewCell
			
			if cell == nil {
				cell = FSTextFieldTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "TextField")
			}
			
			cell!.selectionStyle = UITableViewCellSelectionStyle.None
			
            cell!.label.text = "Name"
			cell!.delegate = self
			cell!.initialize()
            cell!.field.text = self.car.name
//            cell!.field.placeholder = "Car Name"
            cell!.field.attributedPlaceholder = NSAttributedString(string: "Car Name", attributes: [NSForegroundColorAttributeName: UIColor.grayColor()])
            cell!.field.keyboardType = UIKeyboardType.Default
            cell!.field.autocapitalizationType = UITextAutocapitalizationType.Words
			
			return cell!
		}
        
        if indexPath.section == 1 {
            // Number of Seats
            var cell = tableView.dequeueReusableCellWithIdentifier("Stepper", forIndexPath: indexPath) as? StepperTableViewCell
            if cell == nil {
                cell = StepperTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Stepper")
            }
            
            cell!.stepper.maximumValue = 6
            cell!.stepper.minimumValue = 0
            
            if self.car.seats > 0 {
                cell!.stepper.value = Double(self.car.seats)
            } else {
				self.car.seats = 4
                cell!.stepper.value = 4
            }
            
            cell!.label.text = "Number of Seats : " + String(format: "%.0f", cell!.stepper.value)
            
            cell!.initialize()
            cell!.delegate = self
            
            return cell! as UITableViewCell
        }
		
		if indexPath.section == 0 && indexPath.row == 1 {
			var cell: FSTextViewTableViewCell? = tableView.dequeueReusableCellWithIdentifier("TextView", forIndexPath: indexPath) as? FSTextViewTableViewCell
			
			if cell == nil {
				cell = FSTextViewTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "TextView")
			}
            
			cell!.selectionStyle = UITableViewCellSelectionStyle.None
			
			cell!.backgroundColor = UIColor.clearColor()
			cell!.fieldTitle.text = "Description"
			cell!.textView.text = car.carDescription
			cell!.textView.delegate = self
			
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
		} else if indexPath.section == 3 {
			SVProgressHUD.showProgress(1.0, status: "Deleting...", maskType: SVProgressHUDMaskType.Black)
			car.remove({ (err: NSError?, data: AnyObject?) -> Void in
				SVProgressHUD.dismiss()
				self.navigationController!.popViewControllerAnimated(true)
			})
			
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
		imag.allowsEditing = true
		
		self.presentViewController(imag, animated: true, completion: nil)
	}
	
	func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
		self.chosenImage = image
		self.tableView.reloadSections(NSIndexSet(index: 2), withRowAnimation: UITableViewRowAnimation.Fade)
		self.dismissViewControllerAnimated(true, completion: nil)
	}
	
    // MARK: - StepperCellDelegate
    func StepperValueChanged(cell: StepperTableViewCell, value: Double) {
        cell.label.text = "Number of Seats"
        cell.label.text = cell.label.text! + " : " + String(format: "%.0f", value)
		
		self.car.seats = Int(value)
    }
    
    // MARK: - FSTextFieldDelegate
	func FSTextFieldCellEditingBegan(cell: FSTextFieldTableViewCell?) {
		return
	}
	
	func FSTextFieldCellValueChanged(cell: FSTextFieldTableViewCell?, value: NSString?) {
		self.car.name = cell!.field.text
	}
	
	func textViewDidChange(textView: UITextView) {
		self.car.carDescription = textView.text
	}
}

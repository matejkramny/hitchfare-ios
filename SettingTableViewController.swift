
import UIKit
import MessageUI

class SettingTableViewController: UITableViewController, UIActionSheetDelegate, MFMailComposeViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.translucent = false
		self.navigationController!.navigationBar.barStyle = UIBarStyle.Black
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "done:")
        
        var image : UIImage! = UIImage(named: "BackGround")
        var imageView : UIImageView! = UIImageView(image: image)
        imageView.frame = UIScreen.mainScreen().bounds
        self.tableView.backgroundView = imageView
        self.tableView.separatorColor = UIColor.clearColor()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.title = "Back"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = "Settings"
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var vc: FSWebViewController = segue.destinationViewController as FSWebViewController
        vc.title = segue.identifier
        
        if segue.identifier == "Privacy" {
            var vc: FSWebViewController = segue.destinationViewController as FSWebViewController
            vc._flag = segue.identifier
        } else if segue.identifier == "Terms of Service" {
            var vc: FSWebViewController = segue.destinationViewController as FSWebViewController
            vc._flag = segue.identifier
        }
    }
    
    // MARK: Action
    func done(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Override Methods
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if self.tableView.respondsToSelector(Selector("setSeparatorInset:")) {
            self.tableView.separatorInset = UIEdgeInsetsZero
        }
        
        if self.tableView.respondsToSelector(Selector("setLayoutMargins:")) {
            self.tableView.layoutMargins = UIEdgeInsetsZero
        }
    }
    
    // MARK: - TableView Delegate Methods
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0, 1 :
            return 2
		case 2:
			return 1
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : UITableViewCell? = nil
        
        if indexPath.section == 0 {
                cell = tableView.dequeueReusableCellWithIdentifier("SettingCell", forIndexPath: indexPath) as? UITableViewCell
            if indexPath.row == 0 {
                cell!.textLabel!.text = "Need help? Contact us"
            } else if indexPath.row == 1 {
                cell!.textLabel!.text = "Share Fare Shout"
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                cell = tableView.dequeueReusableCellWithIdentifier("PrivacyCell", forIndexPath: indexPath) as? UITableViewCell
                cell!.textLabel!.text = "Privacy"
                cell!.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            } else if indexPath.row == 1 {
                cell = tableView.dequeueReusableCellWithIdentifier("TermsofServiceCell", forIndexPath: indexPath) as? UITableViewCell                
                cell!.textLabel!.text = "Terms of Service"
                cell!.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            }
		} else if indexPath.section == 2 {
			cell = tableView.dequeueReusableCellWithIdentifier("button", forIndexPath: indexPath) as? UITableViewCell
			cell!.textLabel!.text = "Log Out"
		}
			
        return cell!
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableView.rowHeight
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Deselect
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                var actionSheet : UIActionSheet! = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Report", "Suggestion", "Partner with us")
                actionSheet.showInView(self.view!)
            } else {
                var activityStr : String! = "Test"
                var activityView : UIActivityViewController! = UIActivityViewController(activityItems: [activityStr], applicationActivities: nil)
                self.presentViewController(activityView, animated: true, completion: { () -> Void in
                    
                })
            }
        case 1:
            if indexPath.row == 0 {
                // Privacy
            } else {
                // Terms of Service
            }
		case 2:
			currentUser = nil
			sessionCookie = nil
			saveSettings()
			self.navigationController!.dismissViewControllerAnimated(true, completion: nil)
        default:
            break
        }
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var rect: CGRect = CGRectZero
        rect.size.width = tableView.frame.size.width;
        rect.size.height = self.tableView(tableView, heightForHeaderInSection: section)
        
        var view: UIView! = UIView(frame: rect)
        view.backgroundColor = UIColor.clearColor()
        
        var label: UILabel! = UILabel(frame: CGRectMake(12, 0, tableView.bounds.size.width, tableView.sectionHeaderHeight))
        label.shadowOffset = CGSizeMake(0, 1)
        label.shadowColor = UIColor.grayColor()
        label.backgroundColor = UIColor.clearColor()
        label.textColor = UIColor.whiteColor()
        label.font = UIFont.boldSystemFontOfSize(16)
        
        view.addSubview(label)
        
        return view
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if cell.respondsToSelector(Selector("setSeparatorInset:")) {
            cell.separatorInset = UIEdgeInsetsZero
        }
        if cell.respondsToSelector(Selector("setLayoutMargins:")) {
            cell.layoutMargins = UIEdgeInsetsZero
        }
    }
    
    // MARK: - ActionSheet Delegate
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if actionSheet.cancelButtonIndex == buttonIndex { return }
        
        if !MFMailComposeViewController.canSendMail() {
            var alertView : UIAlertView! = UIAlertView(title: nil, message: "Device not configured to send mail.", delegate: nil, cancelButtonTitle: "OK")
            alertView.show()
            return
        }
        
        switch buttonIndex {
        case 1:
            self.displayMailComposerSheet("Report", toRecipients: ["Report@Fareshout.com"])
        case 2:
            self.displayMailComposerSheet("Suggestion", toRecipients: ["Suggestion@Fareshout.com"])
        case 3:
            self.displayMailComposerSheet("Partner", toRecipients: ["Partner@Fareshout.com"])
        default:
            break
        }
    }
    
    // MARK: - Send Mail Methods
    func displayMailComposerSheet(subject: String?, toRecipients: [AnyObject]!) {
        var picker : MFMailComposeViewController! = MFMailComposeViewController()
        picker.mailComposeDelegate = self
        picker.setSubject(subject)
        picker.setToRecipients(toRecipients)
        
        self.presentViewController(picker, animated: true) { () -> Void in
            // MFMailViewController showed done.
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        switch result.value {
        case MFMailComposeResultCancelled.value:
            break
        case MFMailComposeResultSaved.value:
            break
        case MFMailComposeResultSent.value:
            break
        case MFMailComposeResultFailed.value:
            // Result: Mail sending failed
            break
        default:
            // Result: Mail not sent
            break
        }
        
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
    }
}

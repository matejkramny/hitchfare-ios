
import UIKit
import MessageUI

class SettingTableViewController: UITableViewController, UIActionSheetDelegate, MFMailComposeViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.translucent = false
		self.navigationController!.navigationBar.barStyle = UIBarStyle.Black
        
//        self.tableView.registerNib(UINib(nibName: "SettingTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "SettingCell")
        self.title = "Settings"
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "done:")
        
        var image : UIImage! = UIImage(named: "BackGround")
        var imageView : UIImageView! = UIImageView(image: image)
        imageView.frame = UIScreen.mainScreen().bounds
        self.tableView.backgroundView = imageView
        self.tableView.separatorColor = UIColor.clearColor()
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
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0, 1 :
            return 2
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("SettingCell", forIndexPath: indexPath) as? UITableViewCell
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                cell!.textLabel!.text = "Need help? Contact us"
            } else if indexPath.row == 1 {
                cell!.textLabel!.text = "Share Fare Shout"
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                cell!.textLabel!.text = "Privacy"
            } else if indexPath.row == 1 {
                cell!.textLabel!.text = "Terms of Service"
            }
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
                
            } else {
                
            }
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
            println("Report")
            self.displayMailComposerSheet("Report", toRecipients: ["Report Manager", "test"])
        case 2:
            println("Suggestion")
            self.displayMailComposerSheet("Suggestion", toRecipients: ["Suggestion Manager"])
        case 3:
            println("Partner with us")
            self.displayMailComposerSheet("Partner", toRecipients: ["Partner Manager"])
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
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
    }
}

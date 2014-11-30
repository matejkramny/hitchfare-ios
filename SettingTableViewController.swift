
import UIKit

class SettingTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.translucent = false
		self.navigationController!.navigationBar.barStyle = UIBarStyle.Black
        
        self.tableView.registerNib(UINib(nibName: "SettingTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "SettingCell")
        self.title = "Settings"
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "done:")
        
        var image : UIImage! = UIImage(named: "BackGround")
        var imageView : UIImageView! = UIImageView(image: image)
        imageView.frame = UIScreen.mainScreen().bounds
        self.tableView.backgroundView = imageView
        self.tableView.separatorColor = UIColor(red: 145/255.0, green: 101/255.0, blue: 105/255.0, alpha: 1)
    }
    
    // MARK: Action
    func done(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Override Methods
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
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
        if indexPath.section == 0 {
            var cell = tableView.dequeueReusableCellWithIdentifier("", forIndexPath: indexPath) as? UITableViewCell
            
            if indexPath.row == 0 {
                cell!.textLabel!.text = "Need help? Contact us"
            } else {
                
            }
        } else if indexPath.section == 1 {
            
        }
    }
}

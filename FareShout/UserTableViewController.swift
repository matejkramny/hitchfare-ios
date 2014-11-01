//
//  UserTableViewController.swift
//  FareShout
//
//  Created by Matej Kramny on 28/10/2014.
//  Copyright (c) 2014 Matej Kramny. All rights reserved.
//

import UIKit

class UserTableViewController: UITableViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addHike:")
	}
	
	func addHike (sender: AnyObject) {
		self.performSegueWithIdentifier("addJourney", sender: nil)
	}
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		var cell = tableView.dequeueReusableCellWithIdentifier(cellIDForIndexPath(indexPath), forIndexPath: indexPath) as? UITableViewCell
		
		if cell == nil {
			cell = ProfileTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellIDForIndexPath(indexPath))
		}
		
		if indexPath.section == 0 {
			var c = cell as ProfileTableViewCell
			c.nameLabel.text = "Hello world"
		}
		
		return cell!
	}
	
	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 120.0
	}
	
	func cellIDForIndexPath(indexPath: NSIndexPath) -> NSString {
		switch indexPath.section {
		case 0:
			return "profileCell"
		default:
			return ""
		}
	}
}

//
//  ProfileTableViewCell.swift
//  FareShout
//
//  Created by Matej Kramny on 28/10/2014.
//  Copyright (c) 2014 Matej Kramny. All rights reserved.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {
	@IBOutlet weak var nameLabel: UILabel!
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
	}

	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
}

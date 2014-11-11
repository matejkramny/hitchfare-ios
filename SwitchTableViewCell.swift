//
//  SwitchTableViewCell.swift
//  FareShout
//
//  Created by Matej Kramny on 10/11/2014.
//  Copyright (c) 2014 Matej Kramny. All rights reserved.
//

import UIKit

class SwitchTableViewCell: UITableViewCell {
	
	@IBOutlet weak var toggle: UISegmentedControl!
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
	}
	
	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
}

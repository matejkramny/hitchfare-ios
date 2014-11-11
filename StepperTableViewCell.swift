//
//  SwitchTableViewCell.swift
//  FareShout
//
//  Created by Matej Kramny on 10/11/2014.
//  Copyright (c) 2014 Matej Kramny. All rights reserved.
//

import UIKit

class StepperTableViewCell: UITableViewCell {
	
	@IBOutlet weak var stepper: UIStepper!
	@IBOutlet weak var label: UILabel!
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
	}
	
	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
}

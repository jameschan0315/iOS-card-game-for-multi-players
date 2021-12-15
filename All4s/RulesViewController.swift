//
//  RulesViewController.swift
//  War
//
//  Created by Adrian Bartholomew2 on 1/20/16.
//  Copyright © 2016 GB Software. All rights reserved.
//

import UIKit

class RulesViewController: UIViewController {
	
	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var textView: UITextView!
	@IBOutlet weak var stackView: UIStackView!
	override func viewDidLoad() {
		super.viewDidLoad()
		scrollView.contentSize.height = 10000
	}

}

//
//  NavigationViewController.swift
//  War
//
//  Created by Adrian Bartholomew2 on 1/21/16.
//  Copyright © 2016 GB Software. All rights reserved.
//

import UIKit

class NavigationViewController: UINavigationController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// 1
		let rightAddBarButtonItem:UIBarButtonItem = UIBarButtonItem(title: "Add", style: UIBarButtonItem.Style.plain, target: self, action: #selector(addTapped))
		// 2
		let rightSearchBarButtonItem:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(searchTapped))
		// 3
		self.navigationItem.setRightBarButtonItems([rightAddBarButtonItem,rightSearchBarButtonItem], animated: true)
	}
	
	@objc func addTapped() {}
	@objc func searchTapped() {}


}

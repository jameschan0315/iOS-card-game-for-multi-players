//
//  UIViewController.swift
//  All4s
//
//  Created by Adrian Bartholomew on 11/4/17.
//  Copyright © 2017 GB Soft. All rights reserved.
//

import UIKit

extension UIViewController {
	
	func insertChildController(_ childController: UIViewController, intoParentView parentView: UIView) {
		childController.willMove(toParent: self)
		
		self.addChild(childController)
		childController.view.frame = parentView.bounds
		parentView.addSubview(childController.view)
		
		childController.didMove(toParent: self)
	}
	
}



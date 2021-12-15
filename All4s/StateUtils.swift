//
//  StateUtils.swift
//  All4s
//
//  Created by Adrian Bartholomew2 on 10/24/17.
//  Copyright © 2017 GB Soft. All rights reserved.
//

import Foundation

extension State {
	
	func delay(_ delay:Double, closure:@escaping ()->()) {
		DispatchQueue.main.asyncAfter(
			deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
	}
	
	
	func delayInterval(_ interval:Double, selector: Selector) -> Timer {
		return Timer.scheduledTimer(timeInterval: interval, target: self, selector: selector, userInfo: nil, repeats: true)
	}
}

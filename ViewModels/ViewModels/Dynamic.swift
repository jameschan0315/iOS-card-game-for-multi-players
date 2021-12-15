//
//  Dynamic.swift
//  All4s
//
//  Created by Adrian Bartholomew2 on 11/3/17.
//  Copyright © 2017 GB Soft. All rights reserved.
//

class Dynamic<T> {
	typealias Listener = (T) -> ()
	var listener: Listener?
	
	func bind(_ listener: Listener?) {
		self.listener = listener
	}
	
	func bindAndFire(_ listener: Listener?) {
		self.listener = listener
		listener?(value)
	}
	
	var value: T {
		didSet {
			listener?(value)
		}
	}
	
	init(_ v: T) {
		value = v
	}
}

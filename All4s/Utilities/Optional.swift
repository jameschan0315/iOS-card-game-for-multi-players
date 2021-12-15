//
//  Optional.swift
//  All4s
//
//  Created by Adrian Bartholomew2 on 2/18/18.
//  Copyright © 2018 GB Soft. All rights reserved.
//

import Foundation

extension Optional {
	func or<T>(_ defaultValue: T) -> T {
		switch(self) {
		case .none:
			return defaultValue
		case .some(let value):
			return value as! T
		}
	}
}


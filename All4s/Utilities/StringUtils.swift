//
//  String.swift
//  AllFours
//
//  Created by Adrian Bartholomew2 on 1/4/16.
//  Copyright © 2016 GB Software. All rights reserved.
//

import Foundation

extension String {
	var length: Int {
		return self.count
	}
	func trim() -> String {
		return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
	}
	
}

//
//  Personality.swift
//  War
//
//  Created by Adrian Bartholomew2 on 1/6/16.
//  Copyright © 2016 GB Software. All rights reserved.
//

import Foundation

enum PersonalityType {
	case lowducker
	case highducker
}

class Personality: Brain {
	let type: PersonalityType

	init(type: PersonalityType) {
		self.type = type
		super.init()
//		switch (type) {
//			case .HIGHDUCKER:
//				duckHigh = true
//			case .LOWDUCKER:
//				duckHigh = false
//		}
	}
	
}

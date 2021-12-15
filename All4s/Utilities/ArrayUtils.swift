//
//  ArrayUtils.swift
//  All4s
//
//  Created by Adrian Bartholomew2 on 1/27/18.
//  Copyright © 2018 GB Soft. All rights reserved.
//

import Foundation

extension Collection {
	
	subscript(optional i: Index) -> Iterator.Element? {
		return self.indices.contains(i) ? self[i] : nil
	}
	
}

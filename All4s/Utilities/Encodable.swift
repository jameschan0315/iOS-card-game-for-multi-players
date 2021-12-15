//
//  Encodable.swift
//  All4s
//
//  Created by Adrian Bartholomew2 on 2/25/18.
//  Copyright © 2018 GB Soft. All rights reserved.
//

import Foundation

extension Encodable {
	
	// optional variant
	var dictionary: [String: Any]? {
		guard let data = try? JSONEncoder().encode(self) else { return nil }
		return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
	}
	
	func asDictionary() throws -> [String: Any] {
		let data = try JSONEncoder().encode(self)
		guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
			throw NSError()
		}
		return dictionary
	}
}

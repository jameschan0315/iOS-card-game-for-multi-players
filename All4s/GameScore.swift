//
//  GameScore.swift
//  All4s
//
//  Created by Adrian Bartholomew2 on 11/4/17.
//  Copyright © 2017 GB Soft. All rights reserved.
//

import Foundation

struct GamePoints {
	var points = [0, 0]
	subscript(index: Int) -> Int {
		get {return points[index]}
		set(newValue) {
			points[index] = newValue
		}
	}
	mutating func reset() {
		points = [0, 0]
	}
	
}
struct Score {
	var points = [0, 0]
	subscript(index: Int) -> Int {
		get {return points[index]}
		set(newValue) {
			points[index] += newValue
		}
	}
	mutating func reset() {
//        points = [13, 0]
        points = [0, 0]
	}
    mutating func testSet(_ score: [Int]) {
        points = score
    }
}

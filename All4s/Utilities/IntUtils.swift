//
//  Int.swift
//  War
//
//  Created by Adrian Bartholomew2 on 1/4/16.
//  Copyright © 2016 GB Software. All rights reserved.
//

import Foundation

extension Int: Sequence {
    
    func getActualPos(_ truePos: Int) -> Int {
        return (truePos + self) % 4
    }
    
    func getRelPos(_ truePos: Int) -> Int {
        return (self - truePos + 4) % 4
    }
    
    func getRelRemotePos(sourcePos:Int, truePos: Int) -> Int {
        let actual = self.getActualPos(sourcePos)
        return actual.getRelPos(truePos)
        // return (sourcePos + self - truePos + 4) % 4
    }
    
    func incPos() -> Int {
        return (self + 1) % 4
    }
    
    func decPos() -> Int {
        return (self - 1 + 4) % 4
    }

    func cardRankString()->String {
        if self > 10 {
            switch (self) {
                case 11: return "J"
                case 12: return "Q"
                case 13: return "K"
                case 14: return "A"
                default: return ""
            }
        }
        return "\(self)"
    }

	public func makeIterator() -> CountableRange<Int>.Iterator {
		return (0..<self).makeIterator()
	}

	func randomRange(start: Int, to end: Int) -> Int {
		var a = start
		var b = end
		// swap to prevent negative integer crashes
		if a > b {
			swap(&a, &b)
		}
		return Int(arc4random_uniform(UInt32(b - a + 1))) + a
	}
	
	static func rand(_ num: Int) -> Int {
		return Int(arc4random_uniform(UInt32(num)))
	}
	
	static func delay(_ delay:Double, closure:@escaping ()->()) {
		DispatchQueue.main.asyncAfter(
			deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
	}
    
}

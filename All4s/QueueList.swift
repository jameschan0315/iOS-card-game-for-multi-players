//
//  GameStates.swift
//  War
//
//  Created by Adrian Bartholomew2 on 1/9/16.
//  Copyright © 2016 GB Software. All rights reserved.
//

import Foundation

extension QueueList {
    func count() -> Int {
        return list.count
    }
}

class QueueList<T> {
	
    var list: [T] = []
	
    func initItems() {
		self.list = [T]()
	}
	
	func getItems() -> [T] {
		return list
	}
    
    func delayPop(_ delay: Double? = 0, cb: @escaping (_ item: T?)->()) {
        Int.delay(delay!) {
            if self.list.count == 0 { cb(nil) }
            else { cb(self.list.removeLast()) }
        }
    }
    
    func pop() -> T? {
        if list.count == 0 {return nil}
        return list.removeLast()
    }
    
    func shift() -> T? {
        if list.count == 0 {return nil}
        return list.removeFirst()
    }
	
    func push(_ item: T) {
		list.insert(item, at: 0)
	}
	
	func item() -> T? {
		return list.last
	}
}

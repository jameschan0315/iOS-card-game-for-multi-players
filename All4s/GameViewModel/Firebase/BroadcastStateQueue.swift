//
//  BroadcastStateQueue.swift
//  All4s
//
//  Created by Adrian Bartholomew on 11/19/18.
//  Copyright © 2018 GB Soft. All rights reserved.
//

import Foundation

class BroadcastStateQueue {
    static let sharedInstance = BroadcastStateQueue()
    var gameTimer: Timer!
    var target: (([String: Any]) -> ())!
    
    var list = QueueList<[String: Any]>()
    var running = false
    
    
    fileprivate init() {
        list.initItems()
    }
    
    func empty() {
        list.initItems()
    }
    
    func getData() -> [[String: Any]] {
        return list.getItems()
    }
    
    func push(_ data: [String: Any]) {
        list.push(data)
        if gameTimer == nil || !gameTimer.isValid {
            gameTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(next), userInfo: data, repeats: true)
        }
    }
    
    @objc func next(data: Any) {
        if let data = list.pop() {
            if self.list.count() == 0 {
                self.gameTimer.invalidate()
            }
            target(data as [String: Any])
        }
    }
}


//
//  Start.swift
//  War
//
//  Created by Adrian Bartholomew2 on 1/9/16.
//  Copyright © 2016 GB Software. All rights reserved.
//

import Foundation

class StartState: State {
	let Q = StateQueue.sharedInstance
	var QDictionary: [StateName: State]?
	let name: StateName = .start
	weak var gameDelegate: GameDelegate?
    weak var remoteDelegate: RemoteDelegate?
	
	func toQueue(QDictionary: [StateName: State]) {
		self.QDictionary = QDictionary
	}
	
	func update() -> Bool {
		if gameDelegate == nil {return false}
		if !gameDelegate!.areAllSeated() {return false}
		gameDelegate!.gameReset()
		return true
	}
	
	func setGameDelegate(_ gameDelegate: GameDelegate) {
		self.gameDelegate = gameDelegate
	}
    
    func setRemoteDelegate(_ remoteDelegate: RemoteDelegate) {
        self.remoteDelegate = remoteDelegate
    }
	
	func start() {
//        if !Q.update() {return}
        action([:])
		Q.push(QDictionary![.first_JACK]!)
		Q.start()
	}
    
    func action(_ payload: [String : Any]) {
        self.remoteDelegate?.broadcastStateAction("rotateTable", payload: payload, selfNotify: true, broadcast: true)
    }
    
    func onEnter() {}
	
	func onExit() {}
	
	func pause() {}
	
	func resume() {}
}

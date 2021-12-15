//
//  SuspendState.swift
//  War
//
//  Created by Adrian Bartholomew2 on 1/9/16.
//  Copyright © 2016 GB Software. All rights reserved.
//

import Foundation

class SuspendState: State {
	let Q = StateQueue.sharedInstance
	var QDictionary: [StateName: State]?
	let name: StateName = .suspend
	weak var gameDelegate: GameDelegate?
    weak var remoteDelegate: RemoteDelegate?
	
	func toQueue(QDictionary: [StateName: State]) {
		self.QDictionary = QDictionary
	}
	
	func update() -> Bool {
		if gameDelegate == nil {return false}
		return true
	}
	
	func setGameDelegate(_ gameDelegate: GameDelegate) {
		self.gameDelegate = gameDelegate
	}
    
    func setRemoteDelegate(_ remoteDelegate: RemoteDelegate) {
        self.remoteDelegate = remoteDelegate
    }
	
	func start() {
        self.gameDelegate?.suspendGame()
        showContinue()
	}
    
    func showContinue() {
        self.remoteDelegate?.broadcastStateAction("showContinue", payload: nil, selfNotify: true, broadcast: true)
    }
    
    func action(_ payload: [String : Any]) {
    }
    
    func onEnter() {}
	
	func onExit() {}
	
	func pause() {}
	
	func resume() {}
}

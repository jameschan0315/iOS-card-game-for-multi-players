
//
//  StandState.swift
//  War
//
//  Created by Adrian Bartholomew2 on 1/18/16.
//  Copyright © 2016 GB Software. All rights reserved.
//

import Foundation

class StandState: State {
	let Q = StateQueue.sharedInstance
	var QDictionary: [StateName: State]?
	var name: StateName = .stand
	weak var playerDelegate: PlayerDelegate?

	func toQueue(QDictionary: [StateName: State]) {
		self.QDictionary = QDictionary
	}
	
	func update() -> Bool {
		return playerDelegate != nil
	}
	
	func start() {
        playerDelegate?.revealAllHands(true) //TODO: Figure out a different broadcast system
		buildRoundQueue()
		
		Q.start()
	}
	
	func setPlayerDelegate(_ playerDelegate: PlayerDelegate) {
		self.playerDelegate = playerDelegate
	}
	
	func buildRoundQueue() {
		Q.empty()
		Q.push(QDictionary![.round_START]!)
	}
    
    func action(_ payload: [String : Any]) {}
    
    func onEnter() {}
	
	func onExit() {}
	
	func pause() {}
	
	func resume() {}
}

//
//  BegState.swift
//  War
//
//  Created by Adrian Bartholomew2 on 1/18/16.
//  Copyright © 2016 GB Software. All rights reserved.
//

import Foundation


class BegState: State {
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
        playerDelegate?.revealDealerHand(true) // TODO: Figure out how to broacast this!!
		buildRoundQueue()
		
		Q.start()
	}
	
	func setPlayerDelegate(_ playerDelegate: PlayerDelegate) {
		self.playerDelegate = playerDelegate
	}
	
	func buildRoundQueue() {
		Q.empty()
		Q.push(QDictionary![.dealer_OPTIONS]!)
	}
    
    func action(_ payload: [String : Any]) {}
	
	func onEnter() {}
	
	func onExit() {}
	
	func pause() {}
	
	func resume() {}
}

//
//  RoundEndState.swift
//  War
//
//  Created by Adrian Bartholomew2 on 1/9/16.
//  Copyright © 2016 GB Software. All rights reserved.
//

import Foundation

class RoundEndState: State {
	
	var name: StateName = .round_END
	weak var scorable: Scorable?
	weak var gameDelegate: GameDelegate?
	
	func update() -> Bool {
		if let _ = scorable {
			return true
		}
		return false
	}
	
	func start() {
		endRound()
	}
	
	func setScorable(_ scorable: Scorable) {
		self.scorable = scorable
	}
	
	func toQueue(QDictionary: [StateName : State]) {}
	
	fileprivate func endRound() {
		print("end round")
		scorable?.assignRoundWinner()
		scorable?.tallyGameScores()
		gameDelegate?.updateCurrPosition()
	}
	
	func setGameDelegate(_ gameDelegate: GameDelegate) {
		self.gameDelegate = gameDelegate
	}
	
	func toQueue(QDictionary: [String: State]) {}
    
    func action(_ payload: [String : Any]) {}
    
    func onEnter() {}
	
	func onExit() {}
	
	func pause() {}
	
	func resume() {}
}

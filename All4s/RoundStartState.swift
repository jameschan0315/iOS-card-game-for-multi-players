//
//  RoundStartState.swift
//  War
//
//  Created by Adrian Bartholomew2 on 1/9/16.
//  Copyright © 2016 GB Software. All rights reserved.
//

import Foundation

class RoundStartState: State {
	let Q = StateQueue.sharedInstance
	var QDictionary: [StateName: State]?
	var name: StateName = .round_START
	weak var scorable: Scorable?
	weak var subGameDelegate: SubGameDelegate?
	weak var gameDelegate: GameDelegate?
	
	func toQueue(QDictionary: [StateName: State]) {
		self.QDictionary = QDictionary
	}
	
	func update() -> Bool {
        if scorable!.isEnd() {
            Q.empty()
            Q.push(QDictionary![.game_END]!)
            return true
        } else if subGameDelegate!.subGameEnded() {
            Q.push(QDictionary![.sub_END]!)
            return true
        } else {
            if subGameDelegate != nil && scorable != nil && gameDelegate != nil {
                gameDelegate!.updateCurrPosition()
                if subGameDelegate!.beginNewRound() {
                    buildRoundQueue()
                    return true
                }
            }
        }
		print("No subGameDelegate or scorable exists in RoundStartState")
		return false
	}

	func start() {
        print("start round")
		Q.start()
	}
	
	func setScorable(_ scorable: Scorable) {
		self.scorable = scorable
	}
	
	func setSubGameDelegate(_ subGameDelegate: SubGameDelegate) {
		self.subGameDelegate = subGameDelegate
	}
	
	func setGameDelegate(_ gameDelegate: GameDelegate) {
		self.gameDelegate = gameDelegate
	}
	
	func buildRoundQueue() {
		for _ in 0..<4 {Q.push(QDictionary![.play]!)}
		Q.push(QDictionary![.round_END]!)
	}
    
    func action(_ payload: [String : Any]) {}
    
    func onEnter() {}
	
	func onExit() {}
	
	func pause() {}
	
	func resume() {}
}

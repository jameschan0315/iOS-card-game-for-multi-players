//
//  Start.swift
//  War
//
//  Created by Adrian Bartholomew2 on 1/9/16.
//  Copyright © 2016 GB Software. All rights reserved.
//

import Foundation

class TakeOneState: State {
	let Q = StateQueue.sharedInstance
	var QDictionary: [StateName: State]?
	var name: StateName = .take_ONE
	weak var gameDelegate: GameDelegate?
	weak var scorable: Scorable?
	weak var playerDelegate: PlayerDelegate?

	func toQueue(QDictionary: [StateName: State]) {
		self.QDictionary = QDictionary
	}

	func update() -> Bool {
		if gameDelegate == nil || playerDelegate == nil || scorable == nil {
			return false
		}
		gameDelegate!.updateDealer()
		return true
	}

	func start() {
		scorable!.takeOne()
		buildRoundQueue()
        playerDelegate!.revealHands([0, 1, 2, 3], show: true) // TODO: broadcast

		Q.start()
	}

	func setGameDelegate(_ gameDelegate: GameDelegate) {
		self.gameDelegate = gameDelegate
	}

	func setPlayerDelegate(_ playerDelegate: PlayerDelegate) {
		self.playerDelegate = playerDelegate
	}

	func setScorable(_ scorable: Scorable) {
		self.scorable = scorable
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

//
//  Start.swift
//  War
//
//  Created by Adrian Bartholomew2 on 1/9/16.
//  Copyright © 2016 GB Software. All rights reserved.
//

import Foundation

class FirstDealState: State {
	let audio = AudioData.sharedInstance
	var deck: Deck?
	let Q = StateQueue.sharedInstance
	var QDictionary: [StateName: State]?
	weak var subGameDelegate: SubGameDelegate?
	weak var gameDelegate: GameDelegate?
	weak var playerDelegate: PlayerDelegate?
	weak var scorable: Scorable?
	
	var name: StateName = .first_DEAL
	let dealAmt = 6

	
	func setScorable(_ scorable: Scorable) {
		self.scorable = scorable
	}
	
	func setGameDelegate(_ gameDelegate: GameDelegate) {
		self.gameDelegate = gameDelegate
		deck = gameDelegate.getDeck()
	}
	
	func setSubGameDelegate(_ subGameDelegate: SubGameDelegate) {
		self.subGameDelegate = subGameDelegate
	}
	
	func setPlayerDelegate(_ playerDelegate: PlayerDelegate) {
		self.playerDelegate = playerDelegate
	}
	
	func toQueue(QDictionary: [StateName: State]) {
		self.QDictionary = QDictionary
	}
	
	func update() -> Bool {
		if subGameDelegate == nil || scorable == nil || playerDelegate == nil || gameDelegate == nil {
			return false
		}
		return true
	}
	
	func start() {
		subGameDelegate?.shuffleDeck()
		playerDelegate?.emptyHands()
		playerDelegate?.resetGameCards()
		playerDelegate?.resetSort()
        
        subGameDelegate!.setTotalDealt(value: 0)
		
		deal()
		playerDelegate!.revealAllHands(false)
		_ = assignKickBonus(setKick((deck?.pop())!))
		Q.push(QDictionary![.beggar_OPTIONS]!)
		delay(0.6) {
			self.Q.start()
		}
	}
	
	fileprivate func deal() {
		guard let dealerPos = subGameDelegate?.getDealerPlayerPosition() else {return}
		let playerCount = playerDelegate!.playerCount()
		var portions: [[Card]] = [[]]
		for i in 0..<playerCount {
			if i > 0 {portions.append([Card]())}
			for _ in 0..<dealAmt {
				portions[portions.count-1].append((deck?.pop())!)
			}
		}
		var count = 0
		while count < playerCount {
			let i = (dealerPos + 1 + count) % playerCount
			playerDelegate!.setHand(i, hand: portions.removeFirst())
			count += 1
		}
		subGameDelegate!.setTotalDealt(value: subGameDelegate!.getTotalDealt()!+dealAmt)
		print("deal: \(dealAmt)")
	}
	
	func assignKickBonus(_ kick: Card) -> Int {
		scorable!.assignBonus(kick)
		return kick.suitIndex
	}
	
	fileprivate func setKick(_ card: Card) -> Card {
		subGameDelegate!.setKick(card: card)
		audio.playKickSound()
		return card
	}

    func onEnter() {}
	
	func onExit() {}
	
	func pause() {}
	
	func resume() {}
}

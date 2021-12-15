//
//  Start.swift
//  War
//
//  Created by Adrian Bartholomew2 on 1/9/16.
//  Copyright © 2016 GB Software. All rights reserved.
//

import Foundation

class ReDealState: State {
	let audio = AudioData.sharedInstance
	var deck: Deck?
	let Q = StateQueue.sharedInstance
	var QDictionary: [StateName: State]?
	weak var gameDelegate: GameDelegate?
	weak var subGameDelegate: SubGameDelegate?
	weak var scorable: Scorable?
	weak var playerDelegate: PlayerDelegate?
    weak var remoteDelegate: RemoteDelegate?
	
	var name: StateName = .redeal
	var redeal: Bool = false
	var firstDeal: Bool = false
	let dealAmt = 3

	init() {
	}
	
	func toQueue(QDictionary: [StateName: State]) {
		self.QDictionary = QDictionary
	}
	
	func update() -> Bool {
		return scorable != nil
			&& gameDelegate != nil
			&& playerDelegate != nil
			&& subGameDelegate != nil
			&& deck != nil
	}
	
	func start() {
		if (deck?.deck.count)! >= 13 {
			deal()
			playerDelegate!.revealAllHands(true)
		}
		else if deck?.deck.count == 0 {
			Q.push(QDictionary![.first_DEAL_ANIMATION]!)
		}
		if let prevKickSuit = subGameDelegate!.getKick()?.suitIndex {
			if let pop = deck?.pop() {
				scorable!.assignBonus(pop)

                if Constants.getTestSameTrump() ?? (pop.suitIndex == prevKickSuit) {
					_ = setKick(pop)
					print("same trump: \(String(describing: subGameDelegate!.getKick()?.desc))")
                    let redeal = (deck?.deck.count ?? 0) >= 13
                    let msg = redeal ? "Same trump.  Redealing . . ." : "Same trump.  Flipping . . ."
                    action(["msg": msg as Any])
				} else {
					_ = setKick(pop)
					buildRoundQueue()
				}
			} else {print("No more cards to kick")}
		} else {print("Error redealing")}
		
		Q.start()
	}
	
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
    
    func setRemoteDelegate(_ remoteDelegate: RemoteDelegate) {
        self.remoteDelegate = remoteDelegate
    }

	func buildRoundQueue() {
		Q.empty()
		guard let scores = scorable?.getScores() else {return}
		if scores[0] > 13 || scores[1] > 13 { // TODO: Lose magic numbers
			Q.push(QDictionary![.game_END]!)
		} else {
			Q.push(QDictionary![.round_START]!)
		}
	}
	
	fileprivate func deal() {
		guard let playerCount = playerDelegate?.playerCount() else {return}
		guard let currPos = subGameDelegate?.currPosition() else {return}
		var portions: [[Card]] = [[]]
		for i in 0..<playerCount {
			if i > 0 {portions.append([Card]())}
			for _ in 0..<dealAmt {
				portions[portions.count-1].append((deck?.pop())!)
			}
		}
		var count = 0
		while count < playerCount {
			let i = (currPos+count) % playerCount
			playerDelegate!.getPlayerN(i).addCards((portions.removeFirst()))
			count += 1
		}
		if let totalDealt = subGameDelegate?.getTotalDealt() {
			subGameDelegate?.setTotalDealt(value: dealAmt + totalDealt)
		}
		print("deal: \(dealAmt)")
	}
	
	func assignKickBonus(_ card: Card) -> Int {
		audio.playKickSound()
		if isKick(card) {
			scorable!.assignBonus(card)
		}
		return card.suitIndex
	}
	
	fileprivate func isKick(_ card: Card) ->Bool {
		return card === subGameDelegate?.getKick()
	}
	
	fileprivate func setKick(_ card: Card) -> Card {
		subGameDelegate?.setKick(card: card)
		return card
	}
    
    func action(_ payload: [String : Any]) {
        remoteDelegate?.broadcastStateAction("sameTrump", payload: payload, selfNotify: true, broadcast: true)
    }
    
    func onEnter() {}
	
	func onExit() {}
	
	func pause() {}
	
	func resume() {}
}

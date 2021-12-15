//
//  SubGameUtils.swift
//  All4s
//
//  Created by Adrian Bartholomew2 on 1/26/18.
//  Copyright © 2018 GB Soft. All rights reserved.
//

import Foundation

protocol CardDataDelegate: class {
	func getKickSuitIndex() -> Int?
	func getCallSuitIndex() -> Int?
	func highestPlayedTrump() -> Int?
}

protocol SubGameDelegate: class {
	func addSubGame()
	
	func getTotalDealt() -> Int?
	func setTotalDealt(value: Int)
	func getKick() -> Card?
	func setKick(card: Card)
	func getDealerPlayerPosition() -> Int?
	func setDealerPlayerPosition(_ position: Int)
	
	func resetRounds()
	
	func incrementDealer()
	func beginNewRound() -> Bool
	func subGameEnded() -> Bool
	func currPosition() -> Int?
	func resetTotalDealt()
	func shuffleDeck()
}

class SubGameController: CardDataDelegate, SubGameDelegate {
	
	var playerDelegate: PlayerDelegate?
    var remoteDelegate: RemoteDelegate?
	var subGames = [SubGame]()
	var subGame: SubGame?
	var dealerPlayerPosition: Int?
	var hands: [Hand]?
	
	init() {
	}
	
	func getTotalDealt() -> Int? {
		return subGame?.totalDealt
	}
	func setTotalDealt(value: Int) {
		subGame?.totalDealt = value
	}
	func getKick() -> Card? {
		return subGame?.kick
	}
	func setKick(card: Card) {
		subGame?.kick = card
	}
	func getDealerPlayerPosition() -> Int? {
		return dealerPlayerPosition
	}
	func setDealerPlayerPosition(_ position: Int) {
		dealerPlayerPosition = position
	}
	
	func addCardToTable(_ card: Card) {
		guard let round = subGame?.rounds.last else {return}
		round.addCard(card)
		if (card.isJack()) {
			round.jackPlayed = true
            subGame?.jackPlayed = true
		}
	}
	
	func resetRounds() {
		subGame?.resetRounds()
	}
    
    func setPlayerDelegate(_ playerDelegate: PlayerDelegate?) {
        self.playerDelegate = playerDelegate ?? nil
    }
    
    func setRemoteDelegate(_ remoteDelegate: RemoteDelegate?) {
        self.remoteDelegate = remoteDelegate ?? nil
    }
	
	func addSubGame() {
		playerDelegate?.emptyHands()
		if dealerPlayerPosition == nil {
			print("Error: Cannot create SubGame when dealer position is nil")
			return
		}
		dealerPlayerPosition = subGames.count == 0
			? dealerPlayerPosition:
			(subGames.last!.dealerPlayerPosition + 1) % 4
		let subGame = SubGame(dealerPosition: dealerPlayerPosition!)
        subGame.remoteDelegate = remoteDelegate
		subGames.append(subGame)
		self.subGame = subGame
	}
	
	func currSubGame() -> SubGame? {
		return subGames.last
	}
	
	fileprivate func tenPlayed(_ suitIndex: Int) ->Bool {
		if subGame == nil {return false}
		let rounds = subGame!.rounds
		for round in rounds {
			for card in round.plays {
				if card.suitIndex == suitIndex && card.rank == 10 {return true}
			}
		}
		return false
	}
	
	func getKickSuitIndex() -> Int? {
		return subGame?.kick?.suitIndex
	}
	
	func getCallSuitIndex() -> Int? {
		return currRound()?.callCard?.suitIndex
	}
	
	func beginNewRound() -> Bool {
		subGame?.addRound(notifyCardPlayedCallback: notifyCardPlayed)
		return true
	}
	
	func notifyCardPlayed(round: Round) {
        remoteDelegate?.broadcastStateAction("cardPlayed", payload: ["functionPosition": round.firstPosition, "currRound": Round.serializableRound(round)], selfNotify: true, broadcast: true)
	}
	
	func currRound() ->Round? {
		return subGame?.rounds.last
	}
	
	func currPosition() -> Int? {
		return subGame?.currPosition
	}
	
	func subGameEnded() -> Bool {
		guard let rounds = subGame?.rounds else {return false}
		print("rounds: \(String(rounds.count)) == dealt: \(subGame!.totalDealt)")
		return rounds.count == subGame!.totalDealt
	}
	
	func resetTotalDealt() {
		subGame?.setTotalCardsDealt(0)
	}
	
	func incrementDealer() {
		subGame?.dealerPlayerPosition += 1
	}
	
	func shuffleDeck() {
		_ = Deck.sharedInstance.shuffle()
	}
	
	func highestPlayedTrump() ->Int? {
		return highestPlayedInRound(subGame?.kick?.suitIndex)
	}
	
//	func highestPlayed(_ suitIndex: Int?) ->Int? {
//		var high = 0
//		guard let suit = suitIndex else {return nil}
//		guard let rounds = subGame?.rounds else {return nil}
//		for round in rounds {
//			for card in round.plays {
//				if card.suitIndex == suit && card.rank > high {
//					high = card.rank
//				}
//			}
//		}
//		return high
//	}
	
	func highestPlayedInRound(_ suitIndex: Int?) ->Int? {
		guard let suit = suitIndex else {return nil}
		guard let round = subGame?.currRound() else {return nil}
		return round.plays.filter({$0.suitIndex == suit}).max()?.rank
	}
	
	func highestPlayedInSubgame(_ suitIndex: Int?) ->Int? {
		guard let suit = suitIndex else {return nil}
		guard let rounds = subGame?.rounds else {return nil}
		return rounds.flatMap({$0.plays}).filter({$0.suitIndex == suit}).max()?.rank
	}
}

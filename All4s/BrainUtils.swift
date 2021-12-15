//
//  RoundUtils.swift
//  War
//
//  Created by Adrian Bartholomew2 on 1/13/16.
//  Copyright © 2016 GB Software. All rights reserved.
//

import Foundation

extension Brain {
	
	func getCallSuitIndex() -> Int? {
		return data!.currRound()!.callCard?.suitIndex
	}
	
	func bestCard() -> Card {
		var best: Card?
		for (card) in data!.currRound()!.plays {
			if best == nil || card > best! {best = card}
		}
		return best!
	}
	
	func trumpCalled() -> Bool {
		if let play = data!.currRound()!.plays[optional: 0] {
			return play.isTrump()
		}
		return false
	}
	
	func jackOnTable() -> Bool {
		for card in data!.currRound()!.plays {
			if card.isJack() {return true}
		}
		return false
	}

	func tenOnTable() -> Bool {
		for card in data!.currRound()!.plays {
			if card.isTen() {return true}
		}
		return false
	}
	
	func tenCallOnTable() -> Bool {
		if let card = data!.currRound()!.callCard {
			return tenOnTable(card.suitIndex)
		}
		return false
	}
	
	func tenOnTable(_ suitIndex: Int) -> Bool {
		for card in data!.currRound()!.plays {
			if card.suitIndex == suitIndex && card.rank == 10 {return true}
		}
		return false
	}
	
	func highestPlayed() ->Int? {
		return highestPlayed(data!.currRound()!.callCard?.suitIndex)
	}
	
	func highestPlayed(_ suitIndex: Int?) ->Int? {
		var high = 0
		guard let suit = suitIndex else {return nil}
		for card in data!.currRound()!.plays {
			if card.suitIndex == suit && card.rank > high {
				high = card.rank
			}
		}
		return high
	}
	
	func highestTrump() ->Card? {
		let high = topCard()
		return high.isTrump() ? high : nil
	}
	
	func topCard() ->Card {
		var card: Card?
		for play in data!.currRound()!.plays {
			if card == nil || play > card! {card = play}
		}
		return card!
	}
	
	func tenCovered() -> Bool { //TODO: covered by whom
		let tc = topCard()
		return (tc.isCallSuit() && tc.rank > 10) ||
			(!trumpCalled() && tc.isTrump()) // redundant? tc already accounts for trump
	}
	
	func pointsOnTable() ->Int {
		var count = 0
		for card in data!.currRound()!.plays {
			guard let points = card.getGamePoints() else {continue}
			count += points
		}
		return count
	}
	
	func winning() -> Bool {
		guard let currPos = data?.currPosition() else {return false}
		var winningPos = -1
		var winningCard: Card?
			let fp = data!.currRound()!.firstPosition
			for (i, card) in data!.currRound()!.plays.enumerated() {
				if winningCard == nil {
					winningCard = card
					winningPos = fp
				}
				else if card > winningCard! {
					winningCard = card
					winningPos = (fp + i) % 4
				}
		}
		return winningPos % 2 == currPos % 2
	}
}

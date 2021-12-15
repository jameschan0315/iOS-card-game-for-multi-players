//
//  HandUtils.swift
//  War
//
//  Created by Adrian Bartholomew2 on 1/6/16.
//  Copyright © 2016 GB Software. All rights reserved.
//

import Foundation

extension Hand {
	
	func downToSuit(_ suit: Int? = nil) -> Bool {
		return cards.filter{!$0.isCallSuit()}.count == 0
	}
	func downToTrump() -> Bool {
		return cards.filter{!$0.isTrump()}.count == 0
	}
	func hasCallSuit() -> Bool {
		return cards.filter{$0.isCallSuit()}.count > 0
	}

	func hasJack() -> Bool {
		return cards.filter{$0.isJack()}.count > 0
	}
	
	//------------- Trump Based --------------------
	func getTrumps() ->[Card]? {
		let coll = cards.filter{$0.isTrump()}
		return coll.count == 0 ? nil : coll
	}
	
	func getNonTrumps() ->[Card]? {
		let coll = cards.filter{!$0.isTrump()}
		return coll.count == 0 ? nil : coll
	}
	func getLowTrumps() ->[Card]? {
		let coll = cards.filter{$0.isTrump() && $0.rank < 10}
		return coll.count == 0 ? nil : coll
	}
	func getHighTrumps() ->[Card]? {
		let coll = cards.filter{$0.isTrump() && $0.rank > 11}
		return coll.count == 0 ? nil : coll
	}
	func getHigh() -> Card? {
		let coll = cards.filter{$0.isTrump() && $0.rank == 14}
		return coll.count == 0 ? nil : coll[0]
	}
	func getLow() -> Card? {
		let coll = cards.filter{$0.isTrump() && $0.rank == 2}
		return coll.count == 0 ? nil : coll[0]
	}
	func getJack() -> Card? {
		return getJack(cards)
	}
	func getJack(_ cards: [Card]) -> Card? {
		let coll = cards.filter{$0.isTrump() && $0.rank == 11}
		return coll.count == 0 ? nil : coll[0]
	}
	func getTenTrump() -> Card? {
		return getTen()
	}
	func getTen() -> Card? {
		return getTen(cards)
	}
	func getTen(_ cards: [Card]) -> Card? {
		let coll = cards.filter{$0.isTrump() && $0.rank == 10}
		return coll.count == 0 ? nil : coll[0]
	}
	func getNonJacks() ->[Card]? {
		let coll = cards.filter{!$0.isJack()}
		return coll.count == 0 ? nil : coll
	}
	func getHighestTrump() -> Card? {
		return cards.filter{$0.isTrump()}.max()
	}
	func surePoints() -> Int {
		return cards.filter{$0.isTrump() &&
			($0.rank == 2 || $0.rank == 11 || $0.rank == 14)
		}.count
	}
	
	//------------------- Suit Sets ---------------------
	func getNonTrumpSets() -> [Int:[Card]]? {
		var cards: [Int: [Card]]?
		for card in self.cards {
			if !card.isTrump() {
				if cards == nil  {
					cards = [card.suitIndex: [card]]
				} else if cards![card.suitIndex] == nil {
					cards![card.suitIndex] = [card]
				} else {cards![card.suitIndex]!.append(card)}
			}
		}
		return cards
	}
	func getHighSets(_ sets: [Int:[Card]]) -> [Int:[Card]]? {
		var highSets: [Int: [Card]]?
		for (suitIndex, set) in sets {
			for card in set {
				if card.rank > 10 {
					if highSets == nil {
						highSets = [suitIndex: [card]]
					} else if highSets![card.suitIndex] == nil {
						highSets![card.suitIndex] = [card]
					} else {
						highSets![suitIndex]!.append(card)
					}
				}
			}
		}
		return highSets
	}
	func getLowSets(_ sets: [Int:[Card]]) -> [Int:[Card]]? {
		var lowSets: [Int: [Card]]?
		for (suitIndex, set) in sets {
			for card in set {
				if card.rank < 10 {
					if lowSets == nil || lowSets![card.suitIndex] == nil {
						lowSets = [suitIndex: [card]]
					} else if lowSets![card.suitIndex] == nil {
						lowSets![card.suitIndex] = [card]
					} else {
						lowSets![suitIndex]!.append(card)
					}
				}
			}
		}
		return lowSets
	}
	//---------------------------------------------------
	
	func getLeastSet(_ sets: [Int:[Card]]) ->[Card] {
		var leastSet = [Card]()
		var first = true
		for (_, set) in sets {
			if first {
				leastSet = set
				first = false
			}
			else if set.count < leastSet.count {leastSet = set}		}
		return leastSet
	}
	
	func getLowest(_ sets: [Int:[Card]]) ->[Card] {
		var lowest: [Card]?
		for (_, set) in sets {
			let lowestInSet = set.min(by: { (a, b) -> Bool in
				return a.rank > b.rank
			})!
			if lowest == nil {
				lowest = [lowestInSet]
			} else {
				lowest!.append(lowestInSet)
			}
		}
		return lowest!
	}
	func getLowest(_ cards: [Card]) -> Card {
		return cards.min(by: { (a, b) -> Bool in
			return a.rank < b.rank
		})!
	}
	func getSingles(_ sets: [Int:[Card]]) ->[Card]? {
		var singles: [Card]?
		for (_, set) in sets {
			if set.count == 1 {
				if singles == nil {
					singles = [set[0]]
				} else {
					singles!.append(set[0])
				}
			}
		}
		return singles
	}
	func getHighest(_ sets: [Int:[Card]]) ->[Card] {
		var highest: [Card]?
		for (_, set) in sets {
			let highestInSet = set.max(by: { (a, b) -> Bool in
				return a.rank < b.rank
			})!
			if highest == nil {
				highest = [highestInSet]
			} else {
				highest!.append(highestInSet)
			}
		}
		return highest!
	}
	func getHighest(_ cards: [Card]) -> Card {
		return cards.max(by: { (a, b) -> Bool in
			return a.rank > b.rank
		})!
	}
	
	//------------------ Rank Based -------------------
	func getBetters(_ best: Card) ->[Card]? {
		var betters: [Card]?
		for card in cards {
			if card > best {
				if betters == nil {betters = [card]}
				else {betters!.append(card)}
			}
		}
		return betters
	}
	func getDuckers(_ best: Card) ->[Card]? {
		var duckers: [Card]?
		for card in cards {
			if card.isCallSuit() && !card.isTen() && !(card > best) {
				if duckers == nil {duckers = [card]}
				else {duckers!.append(card)}
			}
		}
		return duckers
	}
	func getNonTens() ->[Card]? {
		return getNonTens(cards)
	}
	func getNonTens(_ cards: [Card]) ->[Card]? {
		var nonTens: [Card]?
		for card in cards {
			if card.rank != 10 {
				if nonTens == nil {nonTens = [card]}
				else {nonTens!.append(card)}
			}
		}
		return nonTens
	}
	func getLows() ->[Card]? {
		return getLows(cards)
	}
	func getLows(_ cards: [Card]) ->[Card]? {
		var lows: [Card]?
		for card in cards {
			if card.rank < 10 {
				if lows == nil {lows = [card]}
				else {lows!.append(card)}
			}
		}
		return lows
	}
	func getHighs() ->[Card]? {
		return getHighs(cards)
	}
	func getHighs(_ cards: [Card]) ->[Card]? {
		var highs: [Card]?
		for card in cards {
			if card.rank > 10 {
				if card.rank == 11 && card.isTrump() {continue}
				if highs == nil {highs = [card]}
				else {highs!.append(card)}
			}
		}
		return highs
	}
	func getTenCallSuit() -> Card? {
		if let callCardIndex = cardDataDelegate?.getCallSuitIndex() {
			return getTen(callCardIndex)
		}
		return nil
	}
	func getTen(_ suitIndex: Int) -> Card? {
		for card in cards {
			if card.rank == 10 && card.suitIndex == suitIndex {
				return card
			}
		}
		return nil
	}
	
	//-------------- Counts -----------------
	func tenCount() -> Int {
		var count = 0
		for card in cards {
			if card.rank == 10 {count += 1}
		}
		return count
	}
	func tenSuitCount() -> Int {
		var count = 0
		for card in cards {
			if card.rank == 10 && card.isCallSuit() {count += 1}
		}
		return count
	}
	
	func trumpCount() -> Int {
		if let suitIndex = cardDataDelegate?.getKickSuitIndex() {
			if let suits = getSuitedCards(suitIndex) {
				return suits.count
			}
		}
		return 0
	}
	func highTrumpCount() -> Int {
		var count = 0
		for card in cards {
			if card.isTrump() && card.rank > 9 {count += 1}
		}
		return count
	}
	func getHighestPoints(_ cards: [Card]) ->Card? {
		var highest: Card?
		for card in cards {
			if card.getGamePoints() == nil {continue}
			if highest == nil {highest = card}
			else if card.getGamePoints()! > highest!.getGamePoints()! {
				highest = card
			}
		}
		return highest
	}
	
	//---------------- Suit Based ----------------
	func getSuitedCards(_ suitIndex: Int?) ->[Card]? {
		if suitIndex == nil {return self.cards}
		var cards: [Card]?
		for card in getCards() {
			if card.suitIndex == suitIndex {
				if cards == nil {
					cards = [card]
				} else {cards!.append(card)}
			}
		}
		return cards
	}
	func getSuitedCards(_ suitCard: Card?) ->[Card]? {
		return getSuitedCards(suitCard?.suitIndex)
	}
	func getCallSuits() ->[Card]? {
		return getSuitedCards(cardDataDelegate?.getCallSuitIndex())
	}
	func getLowCallSuits() ->[Card]? {
		var cards: [Card]?
		if let suits = getSuitedCards(cardDataDelegate?.getCallSuitIndex()) {
			for card in suits {
				if card.rank < 10 {
					if cards == nil {
						cards = [card]
					} else {cards!.append(card)}
				}
			}
		}
		return cards
	}
	func getHighCallSuits() ->[Card]? {
		var cards: [Card]?
		if let suits = getSuitedCards(cardDataDelegate?.getCallSuitIndex()) {
			for card in suits {
				if card.rank > 10 {
					if cards == nil {
						cards = [card]
					} else {cards!.append(card)}
				}
			}
		}
		return cards
	}

}

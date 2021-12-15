//
//  CardUtils.swift
//  War
//
//  Created by Adrian Bartholomew2 on 1/6/16.
//  Copyright © 2016 GB Software. All rights reserved.
//

import Foundation

extension Card: Comparable {
	func isTrump() ->Bool {
		return suitIndex == cardDataDelegate.getKickSuitIndex()
	}
	func isUnderTrump() -> Bool {
		let kickSuit = cardDataDelegate.getKickSuitIndex()
		let callSuit = cardDataDelegate.getCallSuitIndex()
		let highestPlayedTrump = cardDataDelegate.highestPlayedTrump()
		if !isTrump() || kickSuit == callSuit || highestPlayedTrump == nil {return false}
		return  rank < highestPlayedTrump!
	}
    func isJack() ->Bool {
        return suitIndex == cardDataDelegate.getKickSuitIndex() &&
            rank == 11
    }
    func isHigh() ->Bool {
        return suitIndex == cardDataDelegate.getKickSuitIndex() &&
            rank == 14
    }
    func isTen() ->Bool {
        return rank == 10
    }
    func isLow() ->Bool {
        return suitIndex == cardDataDelegate.getKickSuitIndex() &&
            rank == 2
	}
	func isCallSuit() -> Bool {
		return suitIndex == cardDataDelegate.getCallSuitIndex()
	}
	func getBonus() ->Int? {
		return Card.bonusMap[rank]
	}
	func getGamePoints() ->Int? {
		return Card.gamePointsMap[rank]
	}
	func isBetter(_ card: Card, callSuitIndex: Int) ->Bool {
//		if card.isTrump() {
//			return isTrump() && self > card
//		}
//		if card.isCallSuit() {
//			return isTrump() || (isCallSuit() && self > card)
//		}
//		return isTrump() || isCallSuit() || self > card
		return self > card
	}
}

func ==(lhs: Card, rhs: Card) ->Bool {
	let data = lhs.cardDataDelegate
	let kick = data.getKickSuitIndex()
	let call = data.getCallSuitIndex()
	
	if (lhs.suitIndex == rhs.suitIndex) {
		return lhs.rank == rhs.rank
	} else {
		return !(
			lhs.suitIndex == kick
				|| rhs.suitIndex == kick
				|| rhs.suitIndex == call
				|| rhs.suitIndex == call
		)
	}
}

func <(lhs: Card, rhs: Card) ->Bool {
	let data = lhs.cardDataDelegate
	let kick = data.getKickSuitIndex()
	let call = data.getCallSuitIndex()
	
	if (lhs.suitIndex == rhs.suitIndex) {
		return lhs.rank < rhs.rank
	} else {
		return (
			rhs.suitIndex == kick
				|| (rhs.suitIndex == call && lhs.suitIndex != kick)
		)
	}
}

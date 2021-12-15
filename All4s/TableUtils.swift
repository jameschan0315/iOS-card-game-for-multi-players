//
//  TableUtils.swift
//  All4s
//
//  Created by Adrian Bartholomew2 on 11/5/17.
//  Copyright © 2017 GB Soft. All rights reserved.
//

import Foundation

extension SubGame {
	
	func callCard() -> Card? {
		return currRound()?.callCard
	}

	func highPlayed() -> Bool {
		guard let round = currRound() else {return false}
		for card in round.plays {
			if card.isHigh() {return true}
		}
		return false
	}
	func whoWasJack() -> Int { // position of Jack
		var pos = -1
		rounds.forEach({
			if $0.jackPlayed {
				for (i, card) in $0.plays.enumerated() {
					if card.isJack() {pos = (i + firstPlayerPosition) % 4}
				}
			}
		})
		return pos
	}
	func jackOnTable() -> Int { // position of Jack
		guard let round = currRound() else {return -1}
		for (i, card) in round.plays.enumerated() {
			if card.isJack() {return (i+firstPlayerPosition)%4}
		}
		return -1
	}
	func jackHung() -> Int { // position of winner
		return 0 // temp
	}
	func tenPlayed() -> Bool {
		return false // temp
	}
	func gamePointsPlayed() -> Int {
		return 0 // temp
	}
	func trumpSafe() -> Bool {
		return false // temp
	}
//	func highestPlayed() -> Card {
//		return Card(index: 0) // temp
//	}
}

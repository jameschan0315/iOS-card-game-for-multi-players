//
//  Round.swift
//  AllFours
//
//  Created by Adrian Bartholomew on 12/27/15.
//  Copyright © 2015 GB Software. All rights reserved.
//

import Foundation

class Round: NSObject {
	
	let updateCurrPositionCallback: ()->()
	let notifyCardPlayedCallback: (Round)->()
	var plays = [Card]() {
		didSet {
			processRound(plays.last!)
			print("Played->\(plays.last!.desc)")
			updateCurrPositionCallback()
			notifyCardPlayedCallback(self)
		}
	}
	let firstPosition: Int
	var winner: Int?

	var callCard: Card?
	var highPlayed = false
	var highestPlayed: Card?
	var kingTrumpPlayed = false
	var queenTrumpPlayed = false
	var jackPlayed = false
	var tenPlayed = false
	var tenTrumpPlayed = false
	var outOfTrumpPositions = [Int]()
    
	init(firstPosition: Int,
		 updateCurrPositionCallback: @escaping ()->(),
		 notifyCardPlayedCallback: @escaping (Round)->()
	) {
        self.firstPosition = firstPosition
		self.updateCurrPositionCallback = updateCurrPositionCallback
		self.notifyCardPlayedCallback = notifyCardPlayedCallback
    }
    
    static func serializableRound(_ round: Round?) -> [String: Any] {
        if round == nil {return [:]}
        var plays: [[String: Any]] = []
        for card in round!.plays {
            plays.append(["index": card.index, "imageName": card.imageName])
        }
        return ["plays": plays]
    }
    
    func addCard(_ card: Card?) {
        if card == nil || isRoundEnded() {return}
		if !isRoundBegun() {
			callCard = card!
			highestPlayed = card!
		}
		plays.append(card!)
    }
	
	private func processRound(_ card: Card) {
		guard let cc = callCard else {return}
		guard let highest = highestPlayed else {return}
		
		if card.suitIndex == cc.suitIndex {
			if card.rank == 10 {tenPlayed = true}
		}
		if card.isTrump() {
			if card.rank == 14 {highPlayed = true}
			else if card.rank == 13 {kingTrumpPlayed = true}
			else if card.rank == 12 {queenTrumpPlayed = true}
			else if card.rank == 11 {jackPlayed = true}
			else if card.rank == 10 {tenTrumpPlayed = true}
		} else if (cc.isTrump()) {
			outOfTrumpPositions.append((firstPosition + plays.count - 1) % 4)
		}
		if card > highest {highestPlayed = card}
	}
	
	func isUnderTrump(_ card: Card) -> Bool {
		if !card.isTrump() || callCard!.isTrump() || !highestPlayed!.isTrump() {return false}
		return  card < highestPlayed!
	}
	
	func isRoundBegun() -> Bool {
		return plays.count > 0
	}
	
	func isRoundEnded() -> Bool {
		return plays.count > 3
	}
}

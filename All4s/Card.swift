//
//  Card.swift
//  AllFours
//
//  Created by Adrian Bartholomew on 12/27/15.
//  Copyright © 2015 GB Software. All rights reserved.
//

import Foundation

class Card {
	static let suits: [String] = ["Clubs", "Diamonds", "Hearts", "Spades"]
	static let bonusMap = [14:1, 6:2, 11:3]
	static let gamePointsMap = [10:10, 11:1, 12:2, 13:3, 14:4]
	
    let suit: String
	var imageName: String {
		get {
			return Card.getImageName(index)
		}
	}
    let index: Int
    let rank: Int
    let suitIndex: Int
    let desc: String
	let cardDataDelegate: CardDataDelegate
    
	init(_ index: Int, cardDataDelegate: CardDataDelegate) {
		self.index = index
		self.cardDataDelegate = cardDataDelegate
		
        self.suitIndex = Card.processCardIndex(index)["suitIndex"] as! Int
		self.suit = Card.processCardIndex(index)["suit"] as! String
		self.rank = Card.processCardIndex(index)["rank"] as! Int
		self.desc = Card.processCardIndex(index)["desc"] as! String
	}
	
	static func processCardIndex(_ index: Int) -> Dictionary<String, Any> {
		let suitIndex = Int((index-1) / 13)
		let rank = (index-1) % 13 + 2
		let suit = Card.suits[suitIndex]
		return [
			"suitIndex": suitIndex,
			"suit": suit,
			"rank": rank,
			"desc": "\(rank.cardRankString())\(suit[suit.startIndex])"
		]
	}
	
	static func getImageName(_ index: Int) -> String {
		let facesIndex = UserDefaults.standard.value(forKey: "facesView") as? Int
		return ImageData.sharedInstance.faces[facesIndex!] + "-card" + String(index+1)
	}
	
	static func getCardDescription(_ index: Int) -> String {
		return Card.processCardIndex(index)["desc"] as! String
	}
	
}

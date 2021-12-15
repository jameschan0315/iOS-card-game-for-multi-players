//
//  Hand.swift
//  AllFours
//
//  Created by Adrian Bartholomew on 12/28/15.
//  Copyright © 2015 GB Software. All rights reserved.
//

import Foundation

enum SortType: Int {
	case ascending = 0
	case descending = 1
}

class Hand {
	weak var cardDataDelegate: CardDataDelegate?
	var updateHandView: (([(String, Int)])->())?
	var cards: [Card] = [] {
		didSet {
			updateHandView?(self.getCardTuples())
		}
	}
	var sortType: SortType? {
		didSet {
			sort()
		}
	}
	
	init() {}
    
    
    static func getSerialized(_ hand: Hand) -> [String: Any] {
        return [:]
    }
	
	func resetSort() {
		sortType = nil
	}
	
	func sort() {
		if sortType == nil {return}
		if sortType == SortType.descending {
			cards = cards.sorted(by:{$0.index > $1.index})
		} else {
			cards = cards.sorted(by:{$1.index > $0.index})
		}
	}
	
	func toggleSort() {
		guard let index = sortType?.rawValue else {return}
		sortType = SortType(rawValue: (1 - index))
	}
    
    func getCardTuples() -> [(String, Int)] {
        return cards.map{card in (card.imageName, card.index)}
    }
    
    func getCardDictArray() -> [[String: Any]] {
        return cards.map{card in ["imageName": card.imageName, "index": card.index]}
    }
    
    static func tuplesToDictArray(_ tuples: [(String, Int)]) -> [[String: Any]] {
        return tuples.map{tuple in ["imageName": tuple.0, "index": tuple.1]}
    }
    
    static func dictArrayToTuples(_ dictArray: [[String: Any]]?) -> [(String, Int)]? {
        if dictArray != nil {
            return dictArray!.map{dict in (dict["imageName"] as! String, dict["index"] as! Int)}
        }
        return nil
    }
	
	func setHandCallback(_ updateHandView: @escaping ([(String, Int)])->()) {
		self.updateHandView = updateHandView
	}
	
	func setCardDataDelegate(_ cardDataDelegate: CardDataDelegate) {
		self.cardDataDelegate = cardDataDelegate
	}
    
    func getCards() -> [Card] {
        return cards
    }
	
	func find(_ index: Int?) -> Card? {
		if index == nil {return nil}
		for c in getCards() {
			if c.index == index {return c}
		}
		return nil
	}
	
	func lastCardIndex() -> Int? {
		if cards.count == 1 {
			return cards[0].index
		}
		return nil
	}
    
    func addCard(_ card: Card) {
        cards.append(card)
    }
    
    func addCards(_ cards: [Card]) {
        self.cards += cards
	}
	
	func setHand(_ cards: [Card]) {
		self.cards = cards
	}
	
	func removeCard(_ card: Card) {
		removeCard(card.index)
	}
	
	func removeCard(_ cardIndex: Int) {
		let index = getCardPos(cardIndex)
		print("attempt to remove card: ", Card.getCardDescription(cardIndex))
		cards.remove(at: index!)
	}
	
	func emptyHand() {
		cards = []
	}
	
	func getCardPos(_ cardIndex: Int) ->Int? {
		return cards.firstIndex(where: {$0.index == cardIndex})
	}
}

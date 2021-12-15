//
//  Deck.swift
//  AllFours
//
//  Created by Adrian Bartholomew on 12/27/15.
//  Copyright © 2015 GB Software. All rights reserved.
//

import Foundation


// Deck of cards class
final class Deck {
	static let sharedInstance = Deck()
	final var cardDataDelegate: CardDataDelegate?
	var deck = [Card]();
	static var cards: [String] = [];
	fileprivate let total = 52
	
	
	static func sharedInstanceWith(cardDataDelegate: CardDataDelegate) -> Deck{
		let instance = Deck.sharedInstance
		instance.cardDataDelegate = cardDataDelegate
		return instance
	}
    
	private init (cardDataDelegate: CardDataDelegate? = nil) {
		self.cardDataDelegate = cardDataDelegate
	}
    
    func reset() -> Deck {
        return initDeck()
    }
    
    // Remove top card of faced down deck
    func pop() -> Card? {
		if deck.count == 0 {return nil}
        return deck.removeLast();
    }
    
    // Set deck to initial order
    fileprivate func initDeck() -> Deck {
        deck = [Card]()
        for i in 1...total {
			deck.append(Card(i, cardDataDelegate: cardDataDelegate!))
        }
        return self
    }
    
    func getCardByIndex(_ index: Int) -> Card {
        return Card(index, cardDataDelegate: cardDataDelegate!)
    }
    
    // Shuffle deck
    func shuffle() -> Deck {
		if self.deck.count != total {
			_ = reset()
		}
        var currentIndex = deck.count
        var temporaryValue: Card
        var randomIndex = 0
        
        while (0 != currentIndex) {
            randomIndex = Int(arc4random_uniform(UInt32(currentIndex)))
            currentIndex -= 1
            temporaryValue = deck[currentIndex]
            deck[currentIndex] = self.deck[randomIndex]
            deck[randomIndex] = temporaryValue
        }
        return self
    }
}

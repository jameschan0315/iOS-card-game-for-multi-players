//
//  Player.swift
//  AllFours
//
//  Created by Adrian Bartholomew on 12/27/15.
//  Copyright © 2015 GB Software. All rights reserved.
//

import Foundation

protocol Playable: class {
	func playCard(_ cardIndex: Int)
	func onCardPlayed(card: Card)
	func showHand()
	func hideHand()
}

protocol AutoPlayable: class {
	func auto(_ name: StateName, currPos: Int)
}

class Player: Playable, AutoPlayable {
	
	var hand = Hand()
	var standCardIndex: Int?
	var animatable: Animatable?
	var isRobot = false
	weak var gameDelegate: GameDelegate?
	weak var userDelegate: Thinkable?
	
	var animateCardToTable: ((Int, Int)->())?

	var teamIndex: Int
    var dealer = false
	var hasUser = false
    let position: Int // 0 - 3
	var gameCards = [Card]()
    var revealHandView: ((Int, Bool)->())?
    var broadcastReveal: ((Int, Bool)->())?
	var handRevealed = false {
		didSet {
			revealHandView?(position, handRevealed)
		}
	}
	
	init(index: Int, teamIndex: Int) {
		position = index
		self.teamIndex = teamIndex
	}
    
    func setHandCallback(_ updateHandView: @escaping (Int, [(String, Int)]) -> ()) {
        hand.setHandCallback() { (cardTuples: [(String, Int)]) -> Void in
            updateHandView(self.position, cardTuples)
        }
    }
	
	func setAnimateCardToTable(_ f: @escaping (Int, Int)->()) {
		animateCardToTable = f
	}
	
	func setRevealHandViewCallback( _ revealHandView: @escaping (Int, Bool)->() ) {
		self.revealHandView = revealHandView
	}
	
	func standUp() {
		hasUser = false
	}
	
	func onCardPlayed(card: Card) {
		standCardIndex = card.index
	}
	
	func showHand() {
		handRevealed = true
	}
	
	func sortHand() {
		if hand.sortType != nil {
			hand.toggleSort()
		} else {
			hand.sortType = SortType.ascending
			hand.sort()
		}
	}
	
	func hideHand() {
		handRevealed = false
	}
    
    func addGameCards(_ plays: [Card]) {
        gameCards += plays
    }
    
//    func getHand() -> Hand {
//        return hand
//    }
	
    fileprivate func getCards() -> [Card] {
        return hand.getCards()
    }
    
    func handPayload() -> [AnyHashable: Any] {
        return ["position": position, "hand": hand]
    }
    
    func addCards(_ cards: [Card]) {
		hand.addCards(cards)
		logHand()
	}
	
	func playCard(_ cardIndex: Int) {
		animateCardToTable?(position, cardIndex)
	}
	
	func removeCard(_ cardIndex: Int) {
		hand.removeCard(cardIndex)
		logHand()
	}
	
	func removeCard(_ card: Card) {
		removeCard(card.index)
	}
	
	func emptyHand() {
		hand.emptyHand()
	}
	
	func setHand(_ cards: [Card]) {
		hand.setHand(cards)
		logHand()
	}
	
	func initHand(_ hand: Hand) {
		self.hand = hand
	}
	
	func logHand() {
		var str = "[\(position)]Hand->"
		for c in hand.getCards() {
			str += c.desc + ", "
		}
		print(str)
	}
	
    func findCard(_ index: Int) -> Card? {
		return hand.find(index)
    }
	
	
	func auto(_ name: StateName, currPos: Int) {
		if currPos != position {
			print("out of turn", currPos, position)
			return
		}
		switch name {
		case .play:
			autoPlay()
		case .beggar_OPTIONS:
			autoBeg()
		case .dealer_OPTIONS:
			autoRedeal()
		default:
			return
		}
	}
	
	func autoPlay() {
		if standCardIndex == nil {
			userDelegate?.chooseCard(hand:hand, callback: {(_ cardIndex: Int) -> Void in
				if self.position == 0 {
					self.gameDelegate?.onPlayAttempt(cardIndex, playerIndex: 0)
				} else {
                    self.gameDelegate?.playCard(["cardIndex": cardIndex, "functionPosition": self.position])
				}
			})
		} else {
			gameDelegate?.onPlayAttempt(standCardIndex!, playerIndex: self.position)
			standCardIndex = nil
		}
	}
	
	func autoBeg() {
		userDelegate?.chooseBegOption(hand:hand, callback: {(beg: Bool) -> Void in
		})
	}
	
	func autoRedeal() {
		userDelegate?.chooseRedealOption(hand:hand, callback: {(redeal: Bool) -> Void in
		})
	}
}

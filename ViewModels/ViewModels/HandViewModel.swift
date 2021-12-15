//
//  HandViewModel.swift
//  All4s
//
//  Created by Adrian Bartholomew2 on 12/10/17.
//  Copyright © 2017 GB Soft. All rights reserved.
//

import Foundation

//protocol AutoPlayable: class {
//	func autoPlay(currPos: Int) -> Int?
//}

class HandViewModel {
	
	weak var handPlayDelegate: HandPlayDelegate?
	var taggedCardIndex: Int?
	var debounce = true

	var vibrateCard: ((Int) -> ())?
	var onCardPlayAnimationComplete: ((Int, Int, Int?) -> ())?
	
	init() {
	}
	
	func setHandPlayDelegate(_ delegate: HandPlayDelegate?) {
		handPlayDelegate = delegate
	}
	
	func onPlayAttempt(_ cardIndex: Int) {
		handPlayDelegate?.onPlayAttempt(cardIndex, playerIndex: 0)
	}
	
	func sortHand() {
		handPlayDelegate?.sortHand()
	}
	
	func convertHandToTuples(_ hand: Hand) -> [(String, Int)] {
		return hand.getCards().map({ (card: Card) -> (String, Int) in
			return (imageName: card.imageName, index: card.index)
		})
	}
	
	func onRepositionCard(cardIndex: Int, newPos: Int) {
		handPlayDelegate?.repositionCard(cardIndex:cardIndex, newPos:newPos)
	}

    func onPlayAnimationComplete(_ index: Int, sourcePos: Int?) {
		onCardPlayAnimationComplete?(index, 0, sourcePos)
		print("MyPlayAnimationComplete")
	}
    
    func removeHandCardPlayed(_ index: Int) {
        
    }
}


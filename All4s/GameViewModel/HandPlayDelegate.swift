//
//  HandPlayDelegate.swift
//  All4s
//
//  Created by Adrian Bartholomew on 11/12/18.
//  Copyright © 2018 GB Soft. All rights reserved.
//

import Foundation

protocol HandPlayDelegate: class {
    func onCardPlayAnimationComplete(_ cardIndex: Int, playerIndex: Int, sourcePos: Int?)
    func onPlayAttempt(_ cardIndex: Int, playerIndex: Int?) // Access from GameDelegate
    func initHand(_ hand: Hand, playerIndex: Int)
    func sortHand()
    func repositionCard(cardIndex: Int, newPos: Int)
}

extension GameViewModel: HandPlayDelegate {
    
    func onCardPlayAnimationComplete(_ cardIndex: Int, playerIndex: Int, sourcePos: Int?) {
        // game = nil on client
        guard let card = game?.players[playerIndex].hand.find(cardIndex) else {
            clientCardPlayed(cardIndex)
            return
        }
        game?.players[playerIndex].removeCard(cardIndex)
        subGameController.addCardToTable(card)
        if playerIndex == 0 {
            self.attemptingPlay = false
            self.playAttemptFailed = false
        }
    }
    
    func initHand(_ hand: Hand, playerIndex: Int) {
        game?.players[playerIndex].initHand(hand)
    }
    
    func sortHand() {
        game?.players[myPosition()].sortHand()
    }
    
    func repositionCard(cardIndex: Int, newPos: Int) {
        let hand = game?.players[0].hand
        if let pos = hand?.getCardPos(cardIndex) {
            let card = hand!.cards[pos]
            hand!.cards.remove(at: pos)
            hand!.cards.insert(card, at: newPos)
        }
    }
}

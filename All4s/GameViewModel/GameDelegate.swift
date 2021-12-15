//
//  GameDelegate.swift
//  All4s
//
//  Created by Adrian Bartholomew on 11/12/18.
//  Copyright © 2018 GB Soft. All rights reserved.
//

import Foundation

protocol GameDelegate: class {
    func getDeck() -> Deck
    func updateCurrPosition()
    func updateDealer()
    func updateBeggar()
    func updatePlayer()
    func areAllSeated() -> Bool
    func isOwner() -> Bool
    func gameReset()
    func playCard(_ playload: [String: Any])
    func onPlayAttempt(_ cardIndex: Int, playerIndex: Int?)
    func suspendGame()
}

extension GameViewModel: GameDelegate {

    func getDeck() -> Deck {
        return game!.deck
    }
    
    func updateCurrPosition() {
        subGameController.subGame?.updateCurrPosition()
    }
    
    func updateDealer() {
        guard let states = game?.states else {return}
        let dState = (states[.dealer_OPTIONS] as! DealerOptionsState)
        guard let pos = subGameController.subGame?.dealerPlayerPosition else {return}
        dState.autoPlayable = game!.players[pos] as AutoPlayable
    }
    
    func updateBeggar() {
        guard let states = game?.states else {return}
        let bOState = (states[.beggar_OPTIONS] as! BeggarOptionsState)
        guard let pos = subGameController.subGame?.firstPlayerPosition else {return}
        bOState.autoPlayable = game!.players[pos] as AutoPlayable
    }
    
    func updatePlayer() {
        guard let states = game!.states else {return}
        let pState = (states[.play] as! PlayState)
        guard let currPos = currPosition() else {
            print("Error: currPosition does not exist")
            return
        }
        pState.autoPlayable = game!.players[currPos] as AutoPlayable
        let actualPos = currPos.getActualPos(truePlayerPosition)
        broadcastHandUpdate(actualPos, validCards: getValidCardsForActualPos(actualPos))
        setHandPlayDelegate?(currPos == 0 ? self : nil)
    }
    
    func suspendGame() {
        setHandPlayDelegate?(nil)
    }
    
    func getValidCardsForActualPos(_ pos: Int) -> [Card] {
        let relPos = pos.getRelPos(truePlayerPosition)
        return game?.players[relPos].hand.cards.filter({
            self.isValidCard($0, playerIndex: relPos)
        }) ?? []
    }
    
    func areAllSeated() -> Bool {
        return getSeatedCount() == 4
    }
    
    func isOwner() -> Bool {
        if Owner == nil {
            return false
        }
        return Owner!
    }
    
    func gameReset() {
        resetScores()
        emptyHands()
    }
    
    func playMyCard(_ payload: [String: Any]) {
        broadcastStateAction("animateFirstPersonPlayCard", payload: payload, broadcast: false)
    }
    
    func playCard(_ payload: [String: Any]) {
        broadcastStateAction("animateThirdPersonPlayCard", payload: payload)
    }
    
    func onPlayAttempt(_ cardIndex: Int, playerIndex: Int? = 0) {
        let payload: [String: Any] = ["cardIndex": cardIndex, "functionPosition": playerIndex!]
        if !isOwner() {
            if !validCardIndices.contains(where: {$0 == cardIndex}) {
                vibrateCard?(cardIndex)
                return
            }
            playMyCard(payload) // Optimism
            broadcastPlayAttempt(truePlayerPosition, cardIndex: cardIndex)
            return
        }
        if Q.getCurrState() == nil {return}
//        let pIndex = (playerIndex ?? 0)!
        if Q.getCurrState()!.name == .beggar_OPTIONS {
            attemptingPlay = false
            game?.players[playerIndex!].standCardIndex = cardIndex
            broadcastStateAction("playStand", payload: payload)
            return
        }
        if isValidPlay(cardIndex, playerIndex: playerIndex!) {
            if playerIndex == 0 { playMyCard(payload) }
            else { playCard(payload) } // For Robots
        }
        attemptingPlay = false
    }
    
    //----------------------
    
    fileprivate func isValidPlay(_ cardIndex: Int, playerIndex: Int) -> Bool {
        if attemptingPlay {
            print("Error: trying to play while another is attempting")
            playAttemptFailed = true
            return false
        }
        attemptingPlay = true
//        if playerIndex != 0 {
        if playerIndex != currPosition() {
            print("Error: not me")
            return false
        }
        if game?.players[playerIndex].hand.cards.count == 1 {
            return true
        }
        if playerIndex != subGameController.currPosition() {
            print("Error: wrong turn")
            return false
        }
        guard let currStateName = Q.currState?.name else {
            print("Error: currState is nil in valid play check")
            return false
        }
        guard let card = game?.players[playerIndex].hand.find(cardIndex) else {
            print("Error: card not found in hand")
            return false
        }
        if currStateName != .beggar_OPTIONS && currStateName != .play {
            print("Error: not play or beggarOptions state")
            return false
        } else if currStateName == .beggar_OPTIONS {return true}
        if !isValidCard(card, playerIndex: playerIndex) {
            print("vibrate card")
            vibrateCard?(card.index)
            if isOwner() {
                broadcastHandUpdate(vibrate: card.index, pos: playerIndex.getActualPos(truePlayerPosition))
            }
            return false
        }
        return true
    }
    
    fileprivate func isValidCard(_ card: Card, playerIndex: Int) -> Bool {
        guard let round = subGameController.subGame?.currRound() else {return false}
        if round.plays.count < 1 {return true}
        let hand = game!.players[playerIndex].hand
        return hand.cards.count == 1 ||
            hand.downToTrump() ||
            (
                !card.isUnderTrump() &&
                    (
                        !hand.hasCallSuit() ||
                            checkFollowSuit(card)
                )
        )
    }
    
    fileprivate func checkFollowSuit(_ card: Card) -> Bool {
        return card.isCallSuit() || card.isTrump()
    }

}

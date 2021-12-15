//
//  Notification.swift
//  All4s
//
//  Created by Adrian Bartholomew2 on 2/25/18.
//  Copyright © 2018 GB Soft. All rights reserved.
//

import Foundation

extension RootViewController {
	
	func addObserver(_ name: String, selector: Selector) {
		NotificationCenter.default.addObserver(self, selector: selector, name: NSNotification.Name(rawValue: name), object: nil)
	}
    
    func setObservers() {
        addObserver("rotateTable", selector: .rotateTable)
        addObserver("sit", selector: .sit)
        addObserver("displayUser", selector: .displayUser)
        addObserver("eraseUser", selector: .eraseUser)
        addObserver("displayRelativeUser", selector: .displayRelativeUser)
        addObserver("setAvatar", selector: .setAvatar)
        addObserver("hideModalView", selector: .hideModalView)
        addObserver("clearTableWithFade", selector: .clearTableWithFade)
        addObserver("beg", selector: .beg)
        addObserver("stand", selector: .stand)
        addObserver("playStand", selector: .playStand)
        addObserver("takeOne", selector: .takeOne)
        addObserver("reDeal", selector: .reDeal)
        addObserver("sameTrump", selector: .sameTrump)
        addObserver("cardPlayed", selector: .cardPlayed)
        addObserver("clientCardPlayed", selector: .clientCardPlayed)
        addObserver("animateDraw", selector: .draw)
        addObserver("newRound", selector: .newRound)
        addObserver("clearTable", selector: .clearTable)
        addObserver("updateKick", selector: .updateKick)
        addObserver("updateTurn", selector: .updateTurn)
        addObserver("updateGamePoints", selector: .updateGamePoints)
        addObserver("updateScore", selector: .updateScore)
        addObserver("showScoreNames", selector: .showScoreNames)
        addObserver("showContinue", selector: .showContinue)
        addObserver("showBeggarOptions", selector: .showBeggarOptions)
        addObserver("showDealerOptions", selector: .showDealerOptions)
        addObserver("showWon", selector: .showWon)
        addObserver("showLost", selector: .showLost)
        addObserver("animateDealing", selector: .animateDealing)
        addObserver("animateTrick", selector: .animateTrick)
        addObserver("animateThirdPersonPlayCard", selector: .animatePlayCard)
        addObserver("animatePlayCard", selector: .animatePlayCard)
    }
	
}

//
//  Selector.swift
//  All4s
//
//  Created by Adrian Bartholomew2 on 2/25/18.
//  Copyright © 2018 GB Soft. All rights reserved.
//

import Foundation

extension Selector {
    static let sit = #selector(RootViewController.sit(_:))
    static let rotateTable = #selector(RootViewController.rotateTable(_:))
    static let setAvatar = #selector(RootViewController.setAvatar(_:))
    static let displayUser = #selector(RootViewController.displayUser(_:))
    static let eraseUser = #selector(RootViewController.eraseUser(_:))
    static let displayRelativeUser = #selector(RootViewController.displayRelativeUser(_:))
	static let hideModalView = #selector(RootViewController.hideModalView(_:))
	static let clearTableWithFade = #selector(RootViewController.clearTableWithFade(_:))
	static let beg = #selector(RootViewController.beg(_:))
	static let stand = #selector(RootViewController.stand(_:))
	static let playStand = #selector(RootViewController.playStand)
	static let takeOne = #selector(RootViewController.takeOne(_:))
	static let reDeal = #selector(RootViewController.reDeal(_:))
	static let sameTrump = #selector(RootViewController.sameTrump(_:))
	static let cardPlayed = #selector(RootViewController.cardPlayed(_:))
    static let clientCardPlayed = #selector(RootViewController.clientCardPlayed(_:))
	static let draw = #selector(RootViewController.animateDraw(_:))
	static let newRound = #selector(RootViewController.newRound(_:))
	static let clearTable = #selector(RootViewController.clearTable)
	static let updateKick = #selector(RootViewController.updateKick(_:))
	static let updateTurn = #selector(RootViewController.updateTurn(_:))
	static let updateGamePoints = #selector(RootViewController.updateGamePoints(_:))
	static let updateScore = #selector(RootViewController.updateScore(_:))
	static let showScoreNames = #selector(RootViewController.showScoreNames(_:))
    static let showContinue = #selector(RootViewController.showContinue(_:))
    static let showBeggarOptions = #selector(RootViewController.showBeggarOptions(_:))
	static let showDealerOptions = #selector(RootViewController.showDealerOptions(_:))
	static let showWon = #selector(RootViewController.showWon(_:))
	static let showLost = #selector(RootViewController.showLost(_:))
	static let animateDealing = #selector(RootViewController.animateDealing(_:))
	static let animateTrick = #selector(RootViewController.animateTrick(_:))
	static let animatePlayCard = #selector(RootViewController.animatePlayCard(_:))
}


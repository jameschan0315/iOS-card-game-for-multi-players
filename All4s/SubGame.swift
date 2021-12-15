//
//  SubGame.swift
//  AllFours
//
//  Created by Adrian Bartholomew on 12/27/15.
//  Copyright © 2015 GB Software. All rights reserved.
//

import Foundation

class SubGame: NSObject {
	weak var scorable: Scorable?
    weak var gameDelegate: GameDelegate?
    weak var remoteDelegate: RemoteDelegate?
	var standCard: Card?
    var jackPlayed = false
	var gamePoints = GamePoints() {
		didSet {
			let payload: [String: [Int]] = ["gamePoints": gamePoints.points]
			print("gamePoints 0: \(gamePoints.points[0])")
			print("gamePoints 1: \(gamePoints.points[1])")
            remoteDelegate?.broadcastStateAction("updateGamePoints", payload: payload, selfNotify: true, broadcast: true)
		}
	}
	var rounds = [Round]() {
		didSet {
            let round = Round.serializableRound(rounds.last)
            let payload: [String: Any] = ["functionPosition": firstPlayerPosition, "plays": round]
            remoteDelegate?.broadcastStateAction("newRound", payload: payload, selfNotify: true, broadcast: true)
		}
	}
	var totalDealt: Int = 0
	var deck = Deck.sharedInstance
	var kick: Card? {
		didSet {
			if kick != nil {
				print("kick: \(kick!.desc)")
			} else {
				print("kick: clear")
			}
            let payload: [String: Any] = ["index": kick?.index as Any, "imageName": kick?.imageName as Any]
            remoteDelegate?.broadcastStateAction("updateKick", payload: payload, selfNotify: true, broadcast: true)
		}
	}
	var currPosition: Int {
		didSet {
            let payload: [String: Any] = ["functionPosition": currPosition]
            remoteDelegate?.broadcastStateAction("updateTurn", payload: payload, selfNotify: true, broadcast: true)
			print("currPosition:", self.currPosition)
		}
	}
	var firstPlayerPosition: Int
	var dealerPlayerPosition: Int {
		didSet {
			dealerPlayerPosition = dealerPlayerPosition % 4
			print("dealerPlayerPosition: \(dealerPlayerPosition)")
			firstPlayerPosition = (dealerPlayerPosition + 1) % 4
			currPosition = firstPlayerPosition
		}
	}
	let scoreValues: [ScoreType: Int] = [.high: 1, .low: 1, .jack: 1, .hangjack: 3, .game: 1]
	
	init(dealerPosition: Int) {
		self.dealerPlayerPosition = dealerPosition
		self.firstPlayerPosition = (dealerPlayerPosition + 1) % 4
		self.currPosition = firstPlayerPosition
		super.init()
		self.resetKick()
		self.resetGamePoints()
	}
	
	func setTotalCardsDealt(_ totalDealt: Int) {
		self.totalDealt = totalDealt
	}
	
	func updateCurrPosition() {
		guard let currStateName = StateQueue.sharedInstance.getCurrState()?.name else {return}
		switch currStateName {
			case .first_DEAL_ANIMATION: currPosition = dealerPlayerPosition
			case .beggar_OPTIONS: currPosition = (dealerPlayerPosition + 1) % 4
			case .dealer_OPTIONS: currPosition = dealerPlayerPosition
			case .round_END:
				currPosition = rounds.last!.winner!
			case .round_START:
				// Stand play
				if rounds.count < 1 {
					currPosition = firstPlayerPosition
				} else {
					currPosition = rounds.last!.winner!
				}
			default:
				guard let firstPosition = currRound()?.firstPosition else {return}
				currPosition = (firstPosition + currRound()!.plays.count) % 4
		}
	}
	
	func addRound(notifyCardPlayedCallback: @escaping (Round)->()) {
		let newRound = Round(firstPosition: currPosition,
							 updateCurrPositionCallback: updateCurrPosition,
							 notifyCardPlayedCallback: notifyCardPlayedCallback)
		rounds.append(newRound)
		print("new round", rounds.count)
	}
	
	// TODO: possible cause for freezing.
	func resetRounds() {
		rounds = [Round]() // TODO: rounds should never be empty. Initialize with round [currPos, dealerPos, kick]
	}
	
	func currRound() -> Round? { // TODO: Should not be optional. Force unwrap of last
		return rounds.last
	}
	
	func resetKick() {
		kick = nil
	}
	
	func resetGamePoints() {
		gamePoints = GamePoints()
	}
}


//
//  ScoreUtils.swift
//  All4s
//
//  Created by Adrian Bartholomew2 on 10/26/17.
//  Copyright © 2017 GB Soft. All rights reserved.
//

import Foundation

protocol Scorable: class {
	func getGamePoints() -> GamePoints?
	func setGamePoints(index: Int, value: Int)
	func getScoreValues() -> [ScoreType: Int]?
	func getScores() -> Score
	func setScores(index: Int, value: Int)
	
	func isEnd() -> Bool
	
	func updateGamePoints()
	func assignRoundWinner()
	func assignBonus(_ kick: Card)
	func tallyGameScores()
	func resetScores()
	func resetScoreNames()
	func resetGamePoints()
	func takeOne()
	
	func processScore()
}

extension GameViewModel: Scorable {
    func updateGamePoints() {}
    
	
	func getScores() -> Score{
		return game!.scores
	}
	
	func setScores(index: Int, value: Int) {
		game!.scores[index] = value
	}
	
	func getGamePoints() -> GamePoints? {
		return subGameController.subGame?.gamePoints
	}
	
	func getScoreValues() -> [ScoreType: Int]? {
		return subGameController.subGame?.scoreValues
	}

	func takeOne() {
		let teamIndex = getNonDealerTeam()?.index
		game!.scores[teamIndex!] = 1
	}
	
	func assignRoundWinner() {
		guard let winner = winningPosition() else {
			print("No winner to assign")
			return
		}
		guard let currRound = subGameController.subGame?.currRound() else {return}
		getPlayerByPosition(winner)?.addGameCards(currRound.plays)
		currRound.winner = winner
		print("**********winner: [\(winner)]**********")
        broadcastStateAction("animateTrick", payload: ["functionPosition": winner])
	}
	
	func winningPosition() -> Int? {
		guard let round = subGameController.subGame?.currRound() else {return nil}
		guard let bestCard = round.plays.max() else {return nil}
		print("bestCard:", bestCard.desc)
		guard let bestIndex = round.plays.firstIndex(of: bestCard) else {return nil}
		return (round.firstPosition + bestIndex) % 4
	}
	
	func assignBonus(_ card: Card) {
        guard let index = getDealerTeam()?.index else {return}
        if let bonus = card.getBonus() {
            setScores(index:index, value:bonus)
        }
	}
    
    func assignKickBonus(_ card: Card) {
        setKick(card)
        assignBonus(card)
    }
    
    func setKick(_ card: Card) {
        subGameController.subGame?.kick = card
    }

	func resetGamePoints() {
		subGameController.subGame?.gamePoints.reset()
		resetGameCards()
	}
	
	func resetScoreNames() {
		game!._teams.forEach({$0.initScores()})
	}
	
	func resetScores() {
		game!.scores.reset()
	}
	
	private func getTargetPlayerPosition(_ card: Card) -> Int? {
		guard let parentRound = subGameController.subGame?.rounds
			.filter({$0.plays.firstIndex(of: card) != nil})[0] else {return nil}
		return (parentRound.plays.firstIndex(of: card)! + parentRound.firstPosition) % 4
	}
	
	private func getTargetTeam(_ card: Card) -> Team? {
		guard let playerPos = getTargetPlayerPosition(card) else {return nil}
		return getTargetTeam(playerPos)
	}
	
	private func getTargetTeam(_ playerPos: Int) -> Team? {
		return game?._teams
			.filter{$0.players.map{$0.position}
				.firstIndex(of: playerPos) != nil}[0]
	}
	
	func processHighPoints() {
		guard let subGame = subGameController.subGame else {return}
		let scoreValues = subGame.scoreValues
		let high = subGame.rounds.flatMap{$0.plays}.max()!
		guard let targetTeam = getTargetTeam(high) else {return}
		targetTeam.scoreNames.append(.high)
		game!.scores[targetTeam.index - (myPosition() % 2)] = scoreValues[.high]!
	}
	
	func processLowPoints() {
		guard let subGame = subGameController.subGame else {return}
		let scoreValues = subGame.scoreValues
		let low = subGame.rounds.flatMap{$0.plays}.filter{$0.isTrump()}.min()!
		guard let targetTeam = getTargetTeam(low) else {return}
		targetTeam.scoreNames.append(.low)
		game?.scores[targetTeam.index + (myPosition() % 2)] = scoreValues[.low]!
	}
	
	func processJackPoints() {
		guard let subGame = subGameController.subGame else {return}
		let scoreValues = subGame.scoreValues
		let jackPlays = subGame.rounds.flatMap{$0.plays}.filter{$0.isJack()}
		if jackPlays.count < 1 {return}
		let jack = jackPlays[0]
		guard let origOwnerPosition = getTargetPlayerPosition(jack) else {return}
		let finalOwner = game!.players
			.filter{$0.gameCards.firstIndex(of: jack) != nil}[0]
		var scoreType: ScoreType!
		if finalOwner.position == origOwnerPosition ||
			finalOwner.position == (origOwnerPosition + 2) % 4 {
			scoreType = .jack
		} else {scoreType = .hangjack}
		guard let targetTeam = getTargetTeam(finalOwner.position) else {return}
		targetTeam.scoreNames.append(scoreType)
		game!.scores[targetTeam.index + (myPosition() % 2)] = scoreValues[scoreType]!
	}
    
    func setGamePoints(index: Int, value: Int) {
        guard let subGame = subGameController.subGame else {return}
        subGame.gamePoints[index] = value
    }
    
    func tallyGameScores() {
        for t in game!._teams {
            setGamePoints(index: t.index, value: t.gameTally())
        }
    }
	
	func processGamePoints() {
		let scoreValues = subGameController.subGame?.scoreValues
		
		let gamePoints0 = game!._teams[0].gamePoints
		let gamePoints1 = game!._teams[1].gamePoints
        
		if gamePoints0 > gamePoints1 {
			game!.scores[(myPosition() % 2)] = scoreValues![.game]!
			game!._teams[0].scoreNames.append(.game)
		} else if gamePoints0 < gamePoints1 {
			game!.scores[1 + (myPosition() % 2)] = scoreValues![.game]!
			game!._teams[1].scoreNames.append(.game)
		} else {
			getNonDealerTeam()?.scoreNames.append(.game)
		}
	}
	
	func processScore() {
		processHighPoints()
		processLowPoints()
		processJackPoints()
		processGamePoints()
        let scoreNames = game!._teams.map{$0.scoreNames.map{$0.rawValue}}
        broadcastStateAction("showScoreNames", payload: ["scoreNames": scoreNames])
	}
	
	func isEnd() ->Bool {
        return game!.scores[0] >= Constants.getWinningScore() || game!.scores[1] >= Constants.getWinningScore()
	}
}

//
//  Team.swift
//  AllFours
//
//  Created by Adrian Bartholomew on 12/27/15.
//  Copyright © 2015 GB Software. All rights reserved.
//

import Foundation

class Team {
    
    let index: Int
    var players: [Player]
	var score: Int
    var gamePoints: Int
    var high: Int
    var low: Int
	var playedJack: Bool {
		didSet {
			print("played jack")
		}
	}
	var scoreNames = [ScoreType]() {
		didSet {
			print("scoreNames", scoreNames)
		}
	}
    
    init(index: Int, player1: Player, player2: Player) {
        self.index = index
        self.players = [player1, player2]
        gamePoints = 0
        score = 0
        high = 1
        low = 15
        playedJack = false
        scoreNames = []
    }
	
	func initScores() {
        gamePoints = 0
        score = 0
        high = 1
        low = 15
        playedJack = false
        scoreNames = []
	}
	
    func addPlayer(_ player: Player) {
        players.append(player)
    }
    
    func removePlayer(_ index: Int) {
        players.remove(at: index)
    }
    
    func gameTally() -> Int {
        var points = 0
        let gameCards = players[0].gameCards + players[1].gameCards
        for card in gameCards {
            if (card.rank < 10) {continue}
			points += card.getGamePoints()!
		}
		gamePoints = points
        return points
    }
}

//
//  SubGame.swift
//  AllFours
//
//  Created by Adrian Bartholomew on 12/27/15.
//  Copyright © 2015 GB Software. All rights reserved.
//

import Foundation

class SubStartState: NSObject, State {
	let data = GameData.sharedInstance
	let Q = StateQueue.sharedInstance
	let playerUtils: PlayerUtils
	
	var name: StateName = .SUB_START
	
	var players = [Player]()
    let teams: [Team]
	var playDelay = 0.3
	
	init(teams: [Team]) {
        self.teams = teams
        for t in teams {
            players.append(t.players[0])
            players.append(t.players[1])
			t.initScores()
		}
		self.playerUtils = PlayerUtils(teams: teams)
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
	}
	
	func update() -> Bool {return true}
	
    func start() {
        data.rounds = []
        beginNewRound((data.dealerPlayerPosition+1) % 4)
		if data.selfTest {playDelay = 0.0}
        delayedAutoPlay(0)
	}
	
	func delayedAutoPlay() {
		delayedAutoPlay(playDelay)
	}
	
	func delayedAutoPlay(d: Double) {
        delay(d) {
            if (self.data.roundEnded()) {
                return self.endRound()
            }
            self.playerUtils.currUser().autoPlay()
        }
    }
    
    private func endRound() {
        print("end round")
		let winner = assignRoundWinner()
		tallyScores()
        if data.subGameEnded() {
			Q.push(SubGameEndState(teams: teams))
			if let state = Q.next() {
				state.start()
			}
			return
        }
        
		beginNewRound(winner)
        delayedAutoPlay(0)
    }
    
    func beginNewRound(currPosition: Int) -> Round {
        let newRound = Round(currPosition: currPosition)
        data.rounds.append(newRound)
        print("new round")
        return newRound
    }
    
    func assignRoundWinner() -> Int {
        let winner = data.winningPosition()
		playerUtils.getPlayerByPosition(winner)!.addGameCards(data.currRound()!.plays)
        return winner
    }
	
	func tallyScores() {
		for t in teams {
			t.gameTally()
			t.scoreTally()
		}
	}
	
	func onEnter() {}
	
	func onExit() {}
	
	func pause() {}
	
	func resume() {}
}

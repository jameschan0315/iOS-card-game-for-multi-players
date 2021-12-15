//
//  PlayerUtils.swift
//  War
//
//  Created by Adrian Bartholomew2 on 1/11/16.
//  Copyright © 2016 GB Software. All rights reserved.
//

import Foundation

protocol PlayerDelegate: class {
	func revealMyHand(_ show: Bool)
	func revealDealerHand(_ show: Bool) 
	func revealHand(_ playerPos: Int, show: Bool)
	func revealHands(_ positions: [Int], show: Bool)
	func revealAllHands(_ show: Bool)
	func setHand(_ playerIndex: Int, hand: [Card])
	func emptyHands()
	func resetGameCards()
	func getPlayerN(_ n: Int) -> Player
	func getPlayers() -> [Player]
	func playerCount() -> Int
	func resetSort()
}

extension GameViewModel: PlayerDelegate {
	
	func getPlayers() -> [Player] {
		return game!.players
	}
	
	func playerCount() -> Int {
		return game!.players.count
	}
    
    func getPlayerByPosition(_ position: Int) -> Player? {
        return game?.players.first{$0.position == position}
    }
	
	func getDealerPlayerPosition() ->Int? {
		return subGameController.dealerPlayerPosition
	}
	
	func getPlayerN(_ n: Int) -> Player {
		return getPlayerByPosition((getDealerPlayerPosition()!+n)%4)!
	}
	
	func getCurrPlayer() -> Player? {
		return getPlayerByPosition(currPosition()!)
	}
	
	func isDealer(_ user: User) ->Bool {
		return getDealer()?.position == user.relativePosition
	}
	
	func getNonDealerTeam() -> Team? {
		if let p = getPlayerByPosition(getDealerPlayerPosition()!.incPos()) {
			return game?._teams[p.teamIndex]
		}
		return nil
	}
	
	func getMyTeam() -> Team {
		let p = getPlayerByPosition(0)
		return game!._teams[p!.teamIndex]
	}
	
	func setHand(_ playerIndex: Int, hand: [Card]) {
		game!.players[playerIndex].setHand(hand)
	}
	
	func emptyHands() {
		getPlayers().forEach({$0.emptyHand()})
	}
	
	func resetGameCards() {
		getPlayers().forEach{$0.gameCards = []}
		game?._teams.forEach{$0.gamePoints = 0}
	}
	
	func resetSort() {
		getPlayers()[myPosition()].hand.resetSort()
	}
	
	func revealMyHand(_ show: Bool) {
		getPlayerByPosition(0)?.handRevealed = show
	}
	
	func revealDealerHand(_ show: Bool = true) {
		getDealer()?.handRevealed = show
	}
	
    func revealHand(_ playerPos: Int, show: Bool = true) {
        getPlayerByPosition(playerPos)?.handRevealed = show
	}
	
	func revealHands(_ positions: [Int], show: Bool = true) {
        positions.forEach { revealHand($0, show: show) }
	}
	
	func revealAllHands(_ show: Bool = true) {
		revealHands([1,2,3,4], show: show);
	}
	
	func getDealer() -> Player? {
		return getPlayerByPosition(getDealerPlayerPosition()!)
	}
	
	func getPlayerTeam(_ player: Player) ->Team? {
		for t in game!._teams {
			if t.players[0] === player || t.players[1] === player {
				return t
			}
		}
		return nil
	}
	
	func getDealerTeam() -> Team? {
		if let p = getPlayerByPosition(getDealerPlayerPosition()!) {
//			return getPlayerTeam(p)
			return game?._teams[p.teamIndex]
		}
		return nil
	}
	
	func setDealerPosition(_ pos: Int) {
		subGameController.subGame?.dealerPlayerPosition = pos
	}
    
    func setDealerPlayerPosition(_ currPos: Int) {
        subGameController.setDealerPlayerPosition(currPos)
    }
}

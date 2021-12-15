//
//  Start.swift
//  War
//
//  Created by Adrian Bartholomew2 on 1/9/16.
//  Copyright © 2016 GB Software. All rights reserved.
//

import Foundation

class BeggarOptionsState: State {
	let Q = StateQueue.sharedInstance
	var QDictionary: [StateName: State]?
	let name: StateName = .beggar_OPTIONS
    weak var gameDelegate: GameDelegate?
    weak var remoteDelegate: RemoteDelegate?
	weak var publicDataDelegate: PublicDataDelegate?
	weak var playerDelegate: PlayerDelegate?
	weak var autoPlayable: AutoPlayable?
	
	func toQueue(QDictionary: [StateName: State]) {
		self.QDictionary = QDictionary
	}
	
	func update() -> Bool {
		guard let gd = gameDelegate else {return false}
		gd.updateCurrPosition()
		gd.updateBeggar()
		gd.updatePlayer()
		return publicDataDelegate?.getScores() != nil
	}
	
	func start() {
		let scores = publicDataDelegate!.getScores()
        self.remoteDelegate?.broadcastStateAction("hideModalView", payload: nil, selfNotify: true, broadcast: true)
        self.remoteDelegate?.broadcastStateAction("clearTable", payload: nil, selfNotify: true, broadcast: true)
		if scores[0] > 13 || scores[1] > 13 { // TODO: Lose magic numbers
			Q.push(QDictionary![.game_END]!)
			Q.start()
			return
		}
        
        guard let currPos = publicDataDelegate?.currPosition() else {return}
        showBeggarOptions(currPos)
        playerDelegate?.revealHand(currPos, show: true)
        
		autoPlayable?.auto(name, currPos: currPos)
	}
	
	func setGameDelegate(_ gameDelegate: GameDelegate) {
		self.gameDelegate = gameDelegate
	}
    
    func setRemoteDelegate(_ remoteDelegate: RemoteDelegate) {
        self.remoteDelegate = remoteDelegate
    }
	
	func setPublicDataDelegate(_ publicDataDelegate: PublicDataDelegate) {
		self.publicDataDelegate = publicDataDelegate
	}
	
	func setPlayerDelegate(_ playerDelegate: PlayerDelegate) {
		self.playerDelegate = playerDelegate
	}
	
    func showBeggarOptions(_ currPos: Int) {
        let selfNotify = currPos == 0
        let payload = selfNotify ? nil : ["functionPosition": currPos]
        self.remoteDelegate?.broadcastStateAction("showBeggarOptions", payload: payload, selfNotify: selfNotify, broadcast: !selfNotify)
	}
    
    func action(_ payload: [String : Any]) {}
	
	func onEnter() {}
	
	func onExit() {}
	
	func pause() {}
	
	func resume() {}
}

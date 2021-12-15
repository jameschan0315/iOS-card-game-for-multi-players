//
//  Start.swift
//  War
//
//  Created by Adrian Bartholomew2 on 1/9/16.
//  Copyright © 2016 GB Software. All rights reserved.
//

import Foundation

class DealerOptionsState: State {
	let name: StateName = .dealer_OPTIONS
	weak var gameDelegate: GameDelegate?
    weak var remoteDelegate: RemoteDelegate?
	weak var publicDataDelegate: PublicDataDelegate?
	weak var playerDelegate: PlayerDelegate?
	weak var autoPlayable: AutoPlayable?

	
	func update() -> Bool {
		guard let gd = gameDelegate else {return false}
		if publicDataDelegate == nil {return false}
		if playerDelegate == nil {return false}
		gd.updateDealer()
		gd.updateCurrPosition()
		if publicDataDelegate?.currPosition() == nil {return false}
		return true
	}
	
	func toQueue(QDictionary: [StateName: State]) {}

	func start() {
        guard let currPos = publicDataDelegate?.currPosition() else {return}        
        showDealerOptions(currPos)
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
	
    func showDealerOptions(_ currPos: Int) {
        let selfNotify = currPos == 0
        let payload = selfNotify ? nil : ["functionPosition": currPos]
        self.remoteDelegate?.broadcastStateAction("showDealerOptions", payload: payload, selfNotify: selfNotify, broadcast: !selfNotify)
	}
	
	func toQueue(QDictionary: [String: State]) {}
    
    func action(_ payload: [String : Any]) {}
    
    func onEnter() {}
	
	func onExit() {}
	
	func pause() {}
	
	func resume() {}
}

//
//  FirstDealAnimationState.swift
//  War
//
//  Created by Adrian Bartholomew2 on 1/20/16.
//  Copyright © 2016 GB Software. All rights reserved.
//

import Foundation

class FirstDealAnimationState: State {
	
	let name: StateName = .first_DEAL_ANIMATION
	let dealAmt = 6
	weak var subGameDelegate: SubGameDelegate?
	weak var gameDelegate: GameDelegate?
    weak var remoteDelegate: RemoteDelegate?
	
	func update() -> Bool {
		if subGameDelegate == nil {return false}
		return true
	}
	
	func toQueue(QDictionary: [StateName: State]) {}
	
	func start() {
		guard let dealerPos = subGameDelegate?.getDealerPlayerPosition() else {return}
        let payload = ["dealAmt":dealAmt, "functionPosition": dealerPos] as [String : Any]
        self.remoteDelegate?.broadcastStateAction("animateDealing", payload: payload, selfNotify: true, broadcast: true)
		gameDelegate?.updateCurrPosition()
	}
	
	func setSubGameDelegate(_ subGameDelegate: SubGameDelegate) {
		self.subGameDelegate = subGameDelegate
	}
	
	func setGameDelegate(_ gameDelegate: GameDelegate) {
		self.gameDelegate = gameDelegate
	}
    
    func setRemoteDelegate(_ remoteDelegate: RemoteDelegate) {
        self.remoteDelegate = remoteDelegate
    }
    
    func onEnter() {}
	
	func onExit() {}
	
	func pause() {}
	
	func resume() {}
}

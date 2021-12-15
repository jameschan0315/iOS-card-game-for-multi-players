//
//  Start.swift
//  War
//
//  Created by Adrian Bartholomew2 on 1/9/16.
//  Copyright © 2016 GB Software. All rights reserved.
//

import Foundation

class PlayState: State {
	var name: StateName = .play
	weak var autoPlayable: AutoPlayable?
	weak var gameDelegate: GameDelegate?
	weak var publicDataDelegate: PublicDataDelegate?
	
	func update() -> Bool {
		guard let gd = gameDelegate else {return false}
		gd.updatePlayer()
		return true
	}
	
	func start() {
		guard let currPos = publicDataDelegate?.currPosition() else {return}
		autoPlayable?.auto(name, currPos: currPos)
	}
	
	func setGameDelegate(_ gameDelegate: GameDelegate) {
		self.gameDelegate = gameDelegate
	}
	
	func setPublicDataDelegate(_ publicDataDelegate: PublicDataDelegate) {
		self.publicDataDelegate = publicDataDelegate
	}
	
	func toQueue(QDictionary: [StateName: State]) {}
    
    func action(_ payload: [String : Any]) {}
    
    func onEnter() {}
	
	func onExit() {}
	
	func pause() {}
	
	func resume() {}
}

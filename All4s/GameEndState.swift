//
//  Start.swift
//  War
//
//  Created by Adrian Bartholomew2 on 1/9/16.
//  Copyright © 2016 GB Software. All rights reserved.
//

import Foundation

class GameEndState: State {
	var name: StateName = .game_END
	weak var remoteDelegate: RemoteDelegate?
	
	func update() -> Bool {
		print("game ended")
		return true
	}
	
	func start() {
		Int.delay(1.5) {
			self.remoteDelegate?.showWinner()
		}
	}
	
	func setRemoteDelegate(_ remoteDelegate: RemoteDelegate) {
		self.remoteDelegate = remoteDelegate
	}
	
	func toQueue(QDictionary: [StateName: State]) {}
    
    func action(_ payload: [String : Any]) {}
    
    func onEnter() {}
	
	func onExit() {}
	
	func pause() {}
	
	func resume() {}
}

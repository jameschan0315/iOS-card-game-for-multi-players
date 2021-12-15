//
//  ReDealAnimationState.swift
//  War
//
//  Created by Adrian Bartholomew2 on 1/20/16.
//  Copyright © 2016 GB Software. All rights reserved.

import Foundation

class ReDealAnimationState: State {
	var name: StateName = .redeal_ANIMATION
	weak var remoteDelegate: RemoteDelegate?
	let dealAmt = 3

	func update() -> Bool {return remoteDelegate != nil}
	
	func toQueue(QDictionary: [StateName: State]) {}
	
	func start() {
//        if !update() {
//            print("ReDealAnimationState update error.")
//            return
//        }
		remoteDelegate?.animateDealing(dealAmt: dealAmt)
	}
	
	func setRemoteDelegate(_ remoteDelegate: RemoteDelegate) {
		self.remoteDelegate = remoteDelegate
	}
    
    func action(_ payload: [String : Any]) {}
    
    func onEnter() {}
	
	func onExit() {}
	
	func pause() {}
	
	func resume() {}
}

                                                              //
//  StateQueue.swift
//  War
//
//  Created by Adrian Bartholomew2 on 1/9/16.
//  Copyright © 2016 GB Software. All rights reserved.
//

import Foundation

final class StateQueue {
	static let sharedInstance = StateQueue()
//    var appDelegate: AppDelegate!
    var gameDelegate: GameDelegate?
	
    var list = QueueList<State>()
	var currState: State?
	
	init() {
        list.initItems()
    }
	
	func empty() {
		list.initItems()
	}
	
	func update() -> Bool {
        if let owner = gameDelegate?.isOwner() {
            if !owner {return false}
//            if !gameDelegate!.areAllSeated() {
//                self.currState = StateName.suspend.getClass()
//                self.currState?.start()
//                return false
//            }
        } else {return false}
		guard let state = currState else{return false}
		return state.update()
	}
	
	func start() {
        next() { state in
            if let currState = state {
                self.currState = currState
                if self.update() { currState.start() }
            }
        }
	}
	
	func getCurrState() ->State? {
		return currState
	}
	
	func getStates() -> [State] {
		return list.getItems()
	}
	
	func push(_ state: State) {
		list.push(state)
		state.onEnter()
	}
	
    fileprivate func next(cb: @escaping (_ state: State?)->()) {
        list.delayPop() { item in
            item?.onExit()
            cb(item)
        }
	}
	
	func pause() {
	}
	
	func resume() {
	}
}

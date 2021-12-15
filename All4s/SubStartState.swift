
//
//  SubStartState
//  AllFours
//
//  Created by Adrian Bartholomew on 12/27/15.
//  Copyright © 2015 GB Software. All rights reserved.
//

import Foundation

class SubStartState: NSObject, State {
	weak var subGameDelegate: SubGameDelegate?
	weak var scorable: Scorable?
	var name: StateName = .sub_START
	let Q = StateQueue.sharedInstance
	var QDictionary: [StateName: State]?
	
	override init() {
		super.init()
	}
	
	func update() -> Bool {
		if subGameDelegate == nil {return false}
		if scorable == nil {return false}
		if scorable!.isEnd() {
			Q.push(QDictionary![.game_END]!)
			Q.start()
			return false
		}
		return true
	}

	func start() {
		subGameDelegate?.addSubGame()
		scorable?.resetGamePoints()
		scorable?.resetScoreNames()
		Q.push(QDictionary![.first_DEAL_ANIMATION]!)
		delay(0.1) {
			self.Q.start()
		}
	}
	
	func setSubGameDelegate(_ subGameDelegate: SubGameDelegate) {
		self.subGameDelegate = subGameDelegate
	}
	
	func setScorable(_ scorable: Scorable) {
		self.scorable = scorable
	}
	
	func toQueue(QDictionary: [StateName: State]) {
		self.QDictionary = QDictionary
	}
    
    func onEnter() {}
	
	func onExit() {}
	
	func pause() {}
	
	func resume() {}
}

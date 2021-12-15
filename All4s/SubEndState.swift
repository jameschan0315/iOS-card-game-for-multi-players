 //
//  SubEndState
//  War
//
//  Created by Adrian Bartholomew2 on 1/9/16.
//  Copyright © 2016 GB Software. All rights reserved.
//

import Foundation

class SubEndState: State {
	var QDictionary: [StateName: State]?
	var name: StateName = .sub_END
	weak var scorable: Scorable?
	
	
	func toQueue(QDictionary: [StateName: State]) {
		self.QDictionary = QDictionary
	}
	
	func update() -> Bool {
		print("subgame ended")
		return true
	}
	
	func start() {
		scorable?.processScore()
	}
	
	func setScorable(_ scorable: Scorable) {
		self.scorable = scorable
	}
    
    func action(_ payload: [String : Any]) {}
    
    func onEnter() {}
	
	func onExit() {}
	
	func pause() {}
	
	func resume() {}
}

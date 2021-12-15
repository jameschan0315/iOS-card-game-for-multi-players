//
//  Start.swift
//  War
//
//  Created by Adrian Bartholomew2 on 1/9/16.
//  Copyright © 2016 GB Software. All rights reserved.
//

import Foundation

class FirstJackState: NSData, State {
    
	let name: StateName = .first_JACK
	let Q = StateQueue.sharedInstance
	var QDictionary: [StateName: State]?
	var currPos: Int = 0
	var gameTimer: Timer!
	
	weak var scorable: Scorable?
	weak var gameDelegate: GameDelegate?
    weak var remoteDelegate: RemoteDelegate?
	weak var subGameDelegate: SubGameDelegate?
	var deck: Deck?
	
	override init() {
		super.init()
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	func toQueue(QDictionary: [StateName: State]) {
		self.QDictionary = QDictionary
	}
	
	func setGameDelegate(_ gameDelegate: GameDelegate) {
		self.gameDelegate = gameDelegate
		deck = gameDelegate.getDeck()
	}
    
    func setRemoteDelegate(_ remoteDelegate: RemoteDelegate) {
        self.remoteDelegate = remoteDelegate
    }
	
	func setSubGameDelegate(_ subGameDelegate: SubGameDelegate) {
		self.subGameDelegate = subGameDelegate
	}
	
	func setScorable(_ scorable: Scorable) {
		self.scorable = scorable
	}
	
	func update() -> Bool {
		_ = deck?.shuffle()
		return true
	}
    
    func cardIntArray(_ cards: [Card]) -> [Int] {
        var ints: [Int] = []
        for card in cards {
            ints.append(card.index)
        }
        return ints
    }
    
    func imageNameArray(_ cards: [Card]) -> [String] {
        var imageNames: [String] = []
        for card in cards {
            imageNames.append(card.imageName)
        }
        return imageNames
    }
	
	func start() {
//        if !Q.update() {return}
		if let drawDeck = drawTillJack() {
            let payload = ["drawnCards": imageNameArray(drawDeck), "functionPosition": currPos] as [String : Any]
            self.action(payload)
		}
	}
	
	func drawTillJack(_ drawDeck: [Card] = [Card]()) -> [Card]? {
		var currDrawDeck = drawDeck
		if let card = deck?.pop() {
			currDrawDeck += [card]
			if card.rank != 11 {
				return drawTillJack(currDrawDeck)
			} else {
				return currDrawDeck
			}
		}
		return nil
	}
    
    func action(_ payload: [String : Any]) {
        self.remoteDelegate?.broadcastStateAction("animateDraw", payload: payload, selfNotify: true, broadcast: true)
    }
	
	func onEnter() {}
	
	func onExit() {}
	
	func pause() {}
	
	func resume() {}
}

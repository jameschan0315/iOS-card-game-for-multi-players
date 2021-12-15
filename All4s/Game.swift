//
//  Game.swift
//  AllFours
//
//  Created by Adrian Bartholomew on 12/27/15.
//  Copyright © 2015 GB Software. All rights reserved.
//

import Foundation

class Game {
	
	let deck: Deck
	let myPlayerPosition: Int = 0
	let _teams: [Team]
	var states: [StateName: State]?
    var cardDataDelegate: CardDataDelegate?
    var remoteDelegate: RemoteDelegate?
	
    var scores = Score() {
        didSet {
            let payload = ["score": scores.points]
            print("score 0: \(scores.points[0])")
            print("score 1: \(scores.points[1])")
            remoteDelegate?.broadcastStateAction("updateScore", payload: payload, selfNotify: true, broadcast: true)
        }
    }
	var playDelay = 0.6
	var users: [User] = []
	let players: [Player] = [
		Player(index: 0, teamIndex: 0),
        Player(index: 1, teamIndex: 1),
        Player(index: 2, teamIndex: 0),
        Player(index: 3, teamIndex: 1)
    ]
	let maxHandCards = 12
	
	init(deck: Deck) {
		self.deck = deck
		_teams = [
			Team(index:0, player1:players[0], player2:players[2]),
			Team(index:1, player1:players[1], player2:players[3])
		]
        setStates()
	}
	
	func setStates() {
		states = [
			.start:					StateName.start.getClass(),
			.first_JACK:			StateName.first_JACK.getClass(),
			.first_DEAL:			StateName.first_DEAL.getClass(),
			.first_DEAL_ANIMATION:	StateName.first_DEAL_ANIMATION.getClass(),
			.beggar_OPTIONS:		StateName.beggar_OPTIONS.getClass(),
			.beg:					StateName.beg.getClass(),
			.stand:					StateName.stand.getClass(),
			.dealer_OPTIONS:		StateName.dealer_OPTIONS.getClass(),
			.take_ONE:				StateName.take_ONE.getClass(),
			.redeal_ANIMATION:		StateName.redeal_ANIMATION.getClass(),
			.redeal:				StateName.redeal.getClass(),
			.round_START:			StateName.round_START.getClass(),
			.round_END:				StateName.round_END.getClass(),
			.sub_START:				StateName.sub_START.getClass(),
			.sub_END:				StateName.sub_END.getClass(),
			.play:
                StateName.play.getClass(),
			.game_END:				StateName.game_END.getClass(),
            .suspend:               StateName.suspend.getClass(),
		]
	}
	
	func setCardDataDelegate(_ cardDataDelegate: CardDataDelegate?) {
		self.cardDataDelegate = cardDataDelegate ?? nil
		setHandCardDataDelegate()
	}
    
    func setRemoteDelegate(_ remoteDelegate: RemoteDelegate?) {
        self.remoteDelegate = remoteDelegate ?? nil
    }
	
	func setHandCardDataDelegate() {
		guard let delegate = cardDataDelegate else {return}
		players.forEach({$0.hand.setCardDataDelegate(delegate)})
	}
	
	func setStateQueues() {
		guard let states = states else {return}
		states[.start]!.toQueue(QDictionary: [.first_JACK: states[.first_JACK]!])
		states[.first_JACK]?.toQueue(QDictionary: [.sub_START: states[.sub_START]!])
		states[.sub_START]?.toQueue(QDictionary: [
			.first_DEAL_ANIMATION: states[.first_DEAL_ANIMATION]!,
			.game_END: states[.game_END]!
		])
		states[.first_DEAL]?.toQueue(QDictionary: [.beggar_OPTIONS: states[.beggar_OPTIONS]!])
		states[.beggar_OPTIONS]?.toQueue(QDictionary: [.game_END: states[.game_END]!])
		states[.stand]?.toQueue(QDictionary: [.round_START: states[.round_START]!])
		states[.beg]?.toQueue(QDictionary: [.dealer_OPTIONS: states[.dealer_OPTIONS]!])
		states[.take_ONE]?.toQueue(QDictionary: [.round_START: states[.round_START]!])
		states[.redeal]?.toQueue(QDictionary: [
            .first_DEAL_ANIMATION: states[.first_DEAL_ANIMATION]!,
            .redeal_ANIMATION: states[.redeal_ANIMATION]!,
			.game_END: states[.game_END]!,
			.round_START: states[.round_START]!
		])
		states[.sub_END]?.toQueue(QDictionary: [.game_END: states[.game_END]!])
		states[.round_START]?.toQueue(QDictionary: [
			.game_END: states[.game_END]!,
			.sub_END: states[.sub_END]!,
			.round_END: states[.round_END]!,
			.play: states[.play]!
		])
	}
	
	func getMe() -> User? {
		return users[0]
	}
}

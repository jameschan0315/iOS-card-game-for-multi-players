                                                                                                     //
//  Robot.swift
//  War
//
//  Created by Adrian Bartholomew2 on 12/31/15.
//  Copyright © 2015 GB Software. All rights reserved.
//

import Foundation
																									
class Robot: User {
	let personality: Personality
	let data = SpeechData.sharedInstance
	
	
    override init(_ playerIndex: Int, id: String? = nil, username: String? = nil, avatarIndex: Int? = nil) {
		self.personality = Personality(type: PersonalityType.highducker)
        super.init(playerIndex, username: username, avatarIndex: -1)
    }

	override func chooseCard(hand:Hand, callback: @escaping (Int) -> Void) {
		if let card = personality.getPlay(hand) {
			callback(card.index)
		}
		else {print("AI error choosing card: \(hand)")}
	}
	
	override func chooseBegOption(hand:Hand, callback: @escaping (Bool) -> Void) {
		if personality.getBeggarOption(hand) {
			callback(true)
            let payload: [String: Any] = ["msg": data.getBegSpeech(), "functionPosition": relativePosition as Any]
            remoteDelegate?.broadcastStateAction("beg", payload: payload, selfNotify: true, broadcast: true)
		} else {
			callback(false)
            let payload: [String: Any] = ["msg": data.getStandSpeech(), "functionPosition": relativePosition as Any]
            remoteDelegate?.broadcastStateAction("stand", payload: payload, selfNotify: true, broadcast: true)
		}
	}
	
	override func chooseRedealOption(hand:Hand, callback: @escaping (Bool) -> Void) {
		if personality.getRedealOption(hand, teamIndex: relativePosition % 2) {
            callback(true)
            let payload: [String: Any] = ["msg": data.getRedealSpeech(), "functionPosition": relativePosition as Any]
            remoteDelegate?.broadcastStateAction("reDeal", payload: payload, selfNotify: true, broadcast: true)
		} else {
            callback(false)
            let payload: [String: Any] = ["msg": data.getTakeOneSpeech(), "functionPosition": relativePosition as Any]
            remoteDelegate?.broadcastStateAction("takeOne", payload: payload, selfNotify: true, broadcast: true)
        }
	}
}

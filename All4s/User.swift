//
//  User
//  AllFours
//
//  Created by Adrian Bartholomew on 12/27/15.
//  Copyright © 2015 GB Software. All rights reserved.
//

import Foundation

protocol Thinkable: class {
	func chooseCard(hand:Hand, callback: @escaping (Int) -> Void)
	func chooseBegOption(hand:Hand, callback: @escaping (Bool) -> Void)
	func chooseRedealOption(hand:Hand, callback: @escaping (Bool) -> Void)
}

class User: Thinkable {
	let id: String
    var playerIndex: Int
    var relativePosition: Int!
    var username: String
    var avatarIndex: Int
    weak var remoteDelegate: RemoteDelegate?
	

    init(_ playerIndex: Int, id: String? = UUID().uuidString, username: String? = nil, avatarIndex: Int? = 0) {
        self.playerIndex = playerIndex
		self.id = id!
        self.username = username ?? "Player\(playerIndex)"
        self.avatarIndex = avatarIndex!
    }
    
    static func getSerialized(_ user: User, useRelativePosition: Bool = false) -> [String: Any] {
        return [
            "avatarIndex": user.avatarIndex,
            "pos": useRelativePosition ? user.relativePosition as Any: user.playerIndex,
            "username": user.username
        ]
    }
    
    func setRemoteDelegate(_ delegate: RemoteDelegate?) {
        remoteDelegate = delegate
    }
	
	func chooseCard(hand:Hand, callback: @escaping (Int) -> Void) {
		if hand.cards.count == 1 {
			callback(hand.cards.last!.index)
		}
	}
	
	func chooseBegOption(hand:Hand, callback: @escaping (Bool) -> Void) {}
	
	func chooseRedealOption(hand:Hand, callback: @escaping (Bool) -> Void) {}
}

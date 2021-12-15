 //
//  GameViewModel.swift
//  All4s
//
//  Created by Adrian Bartholomew2 on 10/30/17.
//  Copyright © 2017 GB Soft. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth
 
 protocol AvatarDelegate: class {
    func setAvatar(_ index: Int, pos: Int)
 }

 class GameViewModel: AvatarDelegate {
    
    func setAvatar(_ index: Int, pos: Int) {
        let actualPos = pos.getActualPos(truePlayerPosition)
        let payload = ["avatarIndex": index, "pos": actualPos] as [String: Any]
        broadcastStateAction("setAvatar", payload: payload, selfNotify: false)
    }
    
//    lazy var functions = Functions.functions()
    
    var isGameBegun = false {
        didSet {
            broadcastStartGame(isGameBegun)
        }
    }
    
    var removeStatesListener: ListenerRegistration!
    var removeHandListener: ListenerRegistration!
    var removeGameStartListener: ListenerRegistration!
    var removePlayAttemptListener: ListenerRegistration!
    var removeOptionsChoicesListener: ListenerRegistration!
    
	var appDelegate: AppDelegate!
    let imageData = ImageData.sharedInstance
    let userDefaults = UserDefaults.standard
	let truePlayerPosition: Int
    var joinedUsers: [User] = [] {
        didSet {
            updateUserDisplay()
        }
    }
    var RoomId: String? = nil
    var GameId: String? = nil
    var UIDocID: String? = nil
    var HandDocIDArray: [String?] = [nil, nil, nil, nil]
    
    var Owner: Bool? = nil
    
	var game: Game? = nil
	let subGameController = SubGameController()
	var Q = StateQueue.sharedInstance
	var attemptingPlay = false
	var playAttemptFailed = false
	var setHandPlayDelegate: ((HandPlayDelegate?)->())?
	var vibrateCard: ((Int)->())?
    var validCardIndices = [Int]()
    let db: Firestore!
    var docPlaysRef: DocumentReference!
    var statesRef: DocumentReference!
    var docUIRef: DocumentReference!
    var docHandRefArray: [DocumentReference?] = [nil, nil, nil, nil]
    
    var updateHandView: (([(String, Int)])->())?
    var revealHandView: ((Bool)->())?

    init(_ pos: Int, gameId: String? = nil, roomId: String? = nil, owner: Bool) {
        db = Firestore.firestore()
        
        truePlayerPosition = pos
        GameId = gameId
        RoomId = roomId
        Owner = owner
        
        // Create User
        let user: User
        if let authUser = Auth.auth().currentUser {
            user = createUser([
                "pos": pos,
                "id": authUser.uid,
                "username": authUser.displayName!,
                "avatarIndex": getAvatarIndex()
            ])
            
            // Create Firebase game table here
            if owner {
                let deck = Deck.sharedInstanceWith(cardDataDelegate: subGameController)
                game = Game(deck: deck)
                fillDBSeat(user)
                setOwnerListeners();
                BroadcastStateQueue.sharedInstance.target = doStateBroadcast
            } else {
                // Or join Firebase game table here
//                Owner = false
                fillDBSeat(user)
                setRemoteListeners()
                BroadcastStateQueue.sharedInstance.target = doStateBroadcast
            }
        } else {
            print("ERROR: Problem getting current User!")
        }
	}
    
    func setOwnerListeners() {
        subGameController.setPlayerDelegate(self)
        subGameController.setRemoteDelegate(self)
        game?.setCardDataDelegate(subGameController)
        game?.setRemoteDelegate(self)
        addUIUpdatesCollection() // Includes setStatesListener
        addHandUpdatesCollection() // Includes setHandListener
        setPlayAttemptListener()
        addOptionsChoicesCollection()
    }
    
    func setRemoteListeners() {
        setStatesListener()
        setHandListener()
        setGameStartListener()
    }
    
    func removeListeners() {
        removeStatesListener?.remove()
        removeHandListener?.remove()
        removeGameStartListener?.remove()
        if (Owner!) {
            subGameController.setPlayerDelegate(nil)
            subGameController.setRemoteDelegate(nil)
            game?.setCardDataDelegate(subGameController)
            game?.setRemoteDelegate(nil)
            removePlayAttemptListener?.remove()
            removeOptionsChoicesListener?.remove()
        }
    }
    
    func clientCardPlayed(_ cardIndex: Int) {
        let payload = ["play":
            ["index": cardIndex,
            "imageName": Card.getImageName(cardIndex)]
        ] as [String : Any]
        NotificationCenter.default.post (
            name: Notification.Name(rawValue: "clientCardPlayed"),
            object: nil,
            userInfo: payload
        )
    }
    
    func setValidCards(_ cardIndices: [Int]) {
        validCardIndices = cardIndices
    }
    
    func getMySub(ownerIndex: Int) -> Int {
        return (truePlayerPosition - ownerIndex + 4) % 2
    }
    
    func addJoinedUsers(_ userData: [[String:Any?]]) {
        let _ = userData.filter { data in
            return !self.joinedUsers.contains(where: { $0.playerIndex == data["pos"] as? Int })
            }
            .map{self.createUser($0 as [String : Any])}
    }
    
    func createUser(_ props: [String: Any]) -> User {
        let id = props["id"] as? String
        if joinedUsers.contains(where: { $0.id == id }) {
            return joinedUsers.filter{ $0.id == id }[0]
        }
        let user = User(
            props["pos"] as! Int, id: id
        )
        user.relativePosition = user.playerIndex.getRelPos(truePlayerPosition)
        user.username = props["username"] as! String
        user.avatarIndex = props["avatarIndex"] as! Int
        user.setRemoteDelegate(self)
        joinedUsers.append(user)
        return user
    }
    
    func removeUser(_ pos: Int) {
        if let index = joinedUsers.firstIndex(where: {$0.playerIndex == pos }) {
            unsitPlayer(joinedUsers[index])
            joinedUsers.remove(at: index)
            game?.states?[.suspend]?.start()
        }
    }

    func getAvatarIndex() -> Int {
        if let index = userDefaults.value(forKey: "avatarView") as? Int {
            return index
        }
        return 0
    }

    func getUsername() -> String {
        if let username = userDefaults.value(forKey: "username") as? String {
            return username
        }
        return "Player\(truePlayerPosition)"
    }
    
    func updateUserDisplay() {
        joinedUsers.forEach{displayUser(User.getSerialized($0, useRelativePosition: isGameBegun))}
        [0, 1, 2, 3]
            .forEach {
                let i = $0
                if let index = joinedUsers.firstIndex(where: {$0.playerIndex == i}) {
                    let user = joinedUsers[index]
                    displayUser(User.getSerialized(user, useRelativePosition: isGameBegun))
                } else {
                    let pos = isGameBegun ? $0.getRelPos(truePlayerPosition) : $0
                    eraseUser(pos)
//                    removeListeners()
                }
        }
    }

    func sitPlayer(_ user: User) {
        guard let game = game else {
            print("No Game model to sit")
            return
        }
        var player: Player
        if let robot = user as? Robot {
            robot.personality.setPublicDataDelegate(self)
            robot.setRemoteDelegate(self)
            robot.relativePosition = robot.playerIndex.getRelPos(truePlayerPosition)
            game.users.append(robot)
            player = game.players[robot.relativePosition]
            player.isRobot = true
            fillDBSeat(robot)
        } else {
            game.users.append(user)
            player = game.players[user.relativePosition]
        }
        player.hasUser = true
        player.gameDelegate = self
        player.userDelegate = game.users.last!
    }

    func sitPlayers() {
        joinedUsers.forEach { sitPlayer($0) }
    }

    func unsitPlayer(_ user: User) {
        guard let game = game else {
            print("No Game model to unsit")
            return
        }
        var player: Player
        if let robot = user as? Robot {
            robot.personality.setPublicDataDelegate(nil)
            robot.setRemoteDelegate(self)
            robot.relativePosition = robot.playerIndex.getRelPos(truePlayerPosition)
            if let index = game.users.firstIndex(where: {$0 === robot}) {
                game.users.remove(at: index)
            }
            player = game.players[robot.relativePosition]
            player.isRobot = false
        } else {
            if let index = game.users.firstIndex(where: {$0 === user}) {
                game.users.remove(at: index)
            }
            player = game.players[user.relativePosition]
        }
        player.hasUser = false
        player.gameDelegate = nil
        player.userDelegate = nil
    }

    func setupGame() {
        isGameBegun = true
        robotFill()
        sitPlayers()
        setDelegates()
        if Owner! { setOwnerListeners() }
        else { setRemoteListeners() }
//        updateUserDisplay()
    }

    func startGame() {
        if !Owner! { return }
        guard let states = game?.states else {return}
        Q.empty()
        Q.push(states[.start]!)
        nextState()
    }

    func continueGame() {
        if !Owner! { return }
        robotFill()
        sitPlayers()
        setHandPlayDelegate?(self)
        //        guard (game?.states) != nil else {return}
        Q.getCurrState()?.start()
    }

    func robotFill() {
        let userPlayerPositions = joinedUsers.map{$0.playerIndex}
        [0, 1, 2, 3]
            .filter{!userPlayerPositions.contains($0)}
            .forEach {
                let robot = Robot($0)
                robot.username = getRobotName()
                robot.relativePosition = robot.playerIndex.getRelPos(truePlayerPosition)
                joinedUsers.append(robot)
        }
    }
    
    func getRobotName() -> String {
        let usedNameIndices = joinedUsers.filter{$0.avatarIndex == -1}.map{$0.username}
        let availableNames = imageData.robotNames.filter{ !usedNameIndices.contains($0) }
        let random = Int.rand(availableNames.count) // TODO: Possible breaking bug if availableNames is nil
        return availableNames[random]
    }

    func getSeatedCount() -> Int {
		var count = 0
		for t in game!._teams {
			for p in t.players {
				if p.hasUser {count += 1}
			}
		}
		return count
	}

	func stand(_ playerIndex: Int) {
		game!.players[playerIndex].hasUser = false
	}

    func userGameStateChoice(_ state: StateName? = nil, delay: Double? = nil, sourcePos: Int? = nil) {
        if !Owner! && sourcePos == nil {
            broadcastOptionsChoice(truePlayerPosition, stateName: state)
            return
        }
		guard let states = game?.states else {return}
		switch (state) {
		case .stand?:
			Q.push(states[.stand]!)
		case .beg?:
			Q.push(states[.beg]!)
		case .take_ONE?:
			Q.push(states[.take_ONE]!)
		case .redeal?:
			Q.push(states[.redeal_ANIMATION]!)
		default: break
		}
		nextState(delay: delay)
	}

    func autoGameStateChoice(_ state: StateName, sourcePos: Int? = nil) {
        // TODO: Maybe the Owner && sourcePos combo is impossible
        if !Owner! || sourcePos != nil  {
            return
        }
		guard let states = game?.states else {return}
		switch (state) {
		case .first_DEAL:
			Q.push(states[.first_DEAL]!)
		case .beggar_OPTIONS:
			Q.push(states[.beggar_OPTIONS]!)
		case .redeal:
			Q.push(states[.redeal]!)
		case .redeal_ANIMATION:
			Q.push(states[.redeal_ANIMATION]!)
		case .round_START:
			Q.push(states[.round_START]!)
		case .sub_START:
			Q.push(states[.sub_START]!)
		default: break
		}
		nextState();
	}
    /////////// END TODO ////////////

    func nextState(delay: Double? = nil) {
        if !Owner! { return }
		Int.delay(delay == nil ? game!.playDelay : delay!) {
			self.Q.start()
		}
	}
    
    //////////// On Animation Completes //////////////
    func animateDrawCardComplete(_ currPos: Int, sourcePos: Int?) {
        if !Owner! || sourcePos != nil { return }
        setDealerPlayerPosition(Constants.getTestDealerPosition() ?? currPos)
        autoGameStateChoice(.sub_START, sourcePos: sourcePos)
    }
    
    func sameTrumpComplete(_ sourcePos: Int?) {
        if let game = game {
            if game.deck.deck.count >= 13 {
                autoGameStateChoice(.redeal_ANIMATION, sourcePos: sourcePos)
            } else {
                autoGameStateChoice(.redeal, sourcePos: sourcePos)
            }
        }
    }
    
    func animateTrickComplete(_ sourcePos: Int?) {
        autoGameStateChoice(.round_START, sourcePos: sourcePos)
    }
    
    func dealHandComplete(_ sourcePos: Int?) {
        autoGameStateChoice(.first_DEAL, sourcePos: sourcePos)
    }
    
    func reDealHandComplete(_ sourcePos: Int?) {
        autoGameStateChoice(.redeal, sourcePos: sourcePos)
    }
    
    func showScoreNamesComplete(_ sourcePos: Int?) {
        autoGameStateChoice(.sub_START, sourcePos: sourcePos)
    }
    
    func playStandComplete(_ sourcePos: Int?) {
        userGameStateChoice(.stand, delay:0, sourcePos: sourcePos)
    }
    
    func begComplete(_ sourcePos: Int?) {
        userGameStateChoice(.beg, sourcePos: sourcePos)
    }
    
    func standComplete(_ sourcePos: Int?) {
        userGameStateChoice(.stand, sourcePos: sourcePos)
    }
    
    func takeOneComplete(_ sourcePos: Int?) {
        userGameStateChoice(.take_ONE, sourcePos: sourcePos)
    }
    
    func reDealComplete(_ sourcePos: Int?) {
        userGameStateChoice(.redeal, sourcePos: sourcePos)
    }
    
    func endGame() {
        if !Owner! { return }
		guard let states = game?.states else {return}
		Q.empty()
		Q.push(states[.game_END]!)
		nextState()
	}

}

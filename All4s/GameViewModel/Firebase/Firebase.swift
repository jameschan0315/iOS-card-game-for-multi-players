//
//  Firebase
//  All4s
//
//  Created by Adrian Bartholomew2 on 10/24/18.
//  Copyright © 2018 GB Soft. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

protocol FirebaseCRUD {
    func getRooms(_ complete: @escaping (_ querySnapshot: QuerySnapshot?) -> ())
}

extension GameViewModel: FirebaseCRUD {
    
    func getRooms(_ complete: @escaping (_ querySnapshot: QuerySnapshot?) -> ()) {
        db.collection("rooms").getDocuments { (querySnapshot, error) in
            if error != nil { complete(nil) }
            complete(querySnapshot)
        }
    }
    
    func createFirebaseGame(_ user: User, roomName: String, complete: @escaping ()->Void) {
        var ref: DocumentReference? = nil
        
        let gameData: [String: Any] = [
            "ownerId": user.id,
            ]
        ref = db.collection("rooms")
            .document(RoomId!)
            .collection("games")
            .addDocument(data:gameData) { err in
            if let err = err {
                print("Error creating new game in Firestore: \(err)")
            } else {
                print("Successfully created new game in Firestore: \(ref!.documentID)")
                self.GameId = ref!.documentID
                complete()
            }
        }
        
    }
    
    func addUIUpdatesCollection() {
        let stateData: [String: Any] = [
            "states": [],
            ]
        db.collection("rooms")
            .document(RoomId!)
            .collection("games")
            .document(GameId!)
            .collection("uiUpdates")
            .document("states")
            .setData(stateData) { err in
            if let err = err {
                print("Error creating new ui doc in Firestore: \(err)")
            } else {
                print("Successfully created new ui doc in Firestore")
                self.setStatesListener()
            }
        }
    }
    
    func addOptionsChoicesCollection() {
        let stateData: [String: Any] = [:]
        db.collection("rooms")
            .document(RoomId!)
            .collection("games")
            .document(GameId!)
            .collection("optionsChoices")
            .document("latest")
            .setData(stateData) { err in
            if let err = err {
                print("Error creating new optionsChoices doc in Firestore: \(err)")
            } else {
                print("Successfully created new optionsChoices doc in Firestore")
                self.setOptionsChoicesListener()
            }
        }
    }
    
    func addHandUpdatesCollection() {
        let handData: [String: Any] = [
            "payload": "",
            ]
        
        [0,1,2,3].forEach { (n) in
            db.collection("rooms")
                .document(RoomId!)
                .collection("games").document(GameId!).collection("hands").document("hand\(n)").setData(handData) { err in
                    if let err = err {
                        print("Error creating new hand\(n) doc in Firestore: \(err)")
                    } else {
                        print("Successfully created new hand\(n) doc in Firestore")
                        if n == self.truePlayerPosition {
                            self.setHandListener()
                        }
                    }
            }
        }
    }
    
    func broadcastStartGame(_ isGameBegun: Bool) {
        let ref = db.collection("rooms")
            .document(RoomId!)
            .collection("games")
            .document(GameId!)
        
        ref.updateData(["isGameBegun": isGameBegun]) { err in
            if let err = err {
                print("Error setting \'isGameBegun\': \(err)")
            } else {
                print("\'isGameBegun\' successfully set")
            }
        }
    }
    
    func broadcastOptionsChoice(_ pos: Int, stateName: StateName?) {
        guard let state = stateName else { return }
        let ref = db.collection("rooms")
            .document(RoomId!)
            .collection("games")
            .document(GameId!).collection("optionsChoices").document("latest")
        
        ref.updateData(["sourcePos": truePlayerPosition, "pos": pos, "stateName": state.rawValue]) { err in
            if let err = err {
                print("Firebase Error choosing option: \(err)")
            } else {
                print("Firebase option choice successfull")
            }
        }
    }
    
    func broadcastPlayAttempt(_ pos: Int, cardIndex: Int) {
        let ref = db.collection("rooms")
            .document(RoomId!)
            .collection("games")
            .document(GameId!)
        
        ref.updateData(["playAttempt": ["pos": pos, "cardIndex": cardIndex]]) { err in
            if let err = err {
                print("Firebase Error attempting play: \(err)")
            } else {
                print("Firebase play attempt successfully updated")
            }
        }
    }
    
    func broadcastHandUpdate(_ pos: Int, validCards: [Card]) {
        let ref = db.collection("rooms")
            .document(RoomId!)
            .collection("games")
            .document(GameId!).collection("hands").document("hand\(pos)")
        let cardIndices = validCards.map{ $0.index }
        ref.setData(["validCards": cardIndices]) { err in
            if let err = err {
                print("Error setting Hand\(pos) validCards: \(err)")
            } else {
                print("Hand\(pos) validCards successfully set")
            }
        }
    }
    
    func broadcastHandUpdate(_ hand: [[String: Any]], pos: Int) {
        let ref = db.collection("rooms")
            .document(RoomId!)
            .collection("games")
            .document(GameId!).collection("hands").document("hand\(pos)")
        
        ref.updateData(["payload": hand]) { err in
            if let err = err {
                print("Error setting Hand\(pos): \(err)")
            } else {
                print("Hand\(pos) successfully set")
            }
        }
    }
    
    func broadcastHandUpdate(_ show: Bool, pos: Int) {
        let ref = db.collection("rooms")
            .document(RoomId!)
            .collection("games")
            .document(GameId!).collection("hands").document("hand\(pos)")
        
        ref.updateData(["show": show]) { err in
            if let err = err {
                print("Error showing Hand\(pos): \(err)")
            } else {
                print("Hand\(pos) show status successfully updated")
            }
        }
    }
    
    func broadcastHandUpdate(vibrate: Int, pos: Int) {
        let ref = db.collection("rooms")
            .document(RoomId!)
            .collection("games")
            .document(GameId!).collection("hands").document("hand\(pos)")
        
        ref.updateData(["vibrate": vibrate]) { err in
            if let err = err {
                print("Error vibrating Card\(vibrate) for hand\(pos): \(err)")
            } else {
                print("Card\(vibrate) vibrate successfully updated for hand\(pos)")
            }
        }
    }
    
    func fillDBSeat(_ user: User) {
        let seatData: [String: Any] = [
            "pos": user.playerIndex,
            "avatar": user.avatarIndex,
            "username": user.username,
            "uid": user.id
        ]
        db.collection("rooms")
            .document(RoomId!).collection("games").document(GameId!)
            .collection("seats").document("seat\(user.playerIndex)").updateData(seatData)
        { err in
            if let err = err {
                print("Error updating \'seats\': \(err)")
            } else {
                print("\'seats\' successfully updated")
                self.addSeatToUser(uid: user.id, seatNum: user.playerIndex)
            }
        }
    }
    
    func addSeatToUser(uid: String, seatNum: Int) {
        db.collection("users")
            .document(uid).updateData(["room": RoomId!, "game": GameId!, "seat": seatNum])
        { err in
            if let err = err {
                print("Error adding seat to User: \(err)")
            } else {
                print("Seat successfully added to User")
            }
        }
    }
    
    func broadcastStateAction(_ funcName: String, payload: [String: Any]? = [:], selfNotify: Bool = true, broadcast: Bool = true) {
        let BSQ = BroadcastStateQueue.sharedInstance
        if selfNotify {
            NotificationCenter.default.post (
                name: Notification.Name(rawValue: funcName),
                object: nil,
                userInfo: payload
            )
        }
        if !broadcast { return }
        let payloadJson = payload == nil ? "" : JSONEncode(payload!)
        let stateData: [String: Any] = [
            "sourcePos": truePlayerPosition,
            "funcName": funcName,
            "funcPayload": payloadJson
        ]
        BSQ.push(stateData)
    }
    
    func doStateBroadcast(_ stateData: [String: Any]) {
        let ref = db.collection("rooms")
            .document(RoomId!)
            .collection("games")
            .document(GameId!)
            .collection("uiUpdates")
            .document("states")
        
        ref.setData([
            "states": stateData
        ]) { err in
            if let err = err {
                print("Error updating \'states\': \(err)")
            } else {
                print("\(stateData["funcName"] as! String) successfully updated")
            }
        }
    }
    
    func remoteStateUpdate(documentSnapshot: DocumentSnapshot?, error: Error?) {
        guard let doc = documentSnapshot, doc.exists else {return}
        let data = doc.data()
        guard let state = data?["states"] as? [String: Any] else {return}
        
        let sourcePos = state["sourcePos"] as? Int
        if sourcePos == self.truePlayerPosition {return}
        
        guard let funcName = state["funcName"] as? String else {return}
        guard let funcPayloadJson = state["funcPayload"] as? String else {return}
        var payload: [String: Any] = [:]
        if funcPayloadJson != "" {
            payload = JSONDecode(funcPayloadJson) as! [String : Any]
        }
        print("remote: funcName: \(funcName), payload: \(payload)")
        
        remoteNotifyUI(["funcName": funcName, "payload": payload, "sourcePos": sourcePos as Any])
    }
    
    func remoteSeatUpdate(documentSnapshot: DocumentSnapshot?, error: Error?) {
        guard let doc = documentSnapshot, doc.exists else {return}
        let data = doc.data()
        
        let avatar = data?["avatar"] as? Int
        let pos = data?["pos"] as? Int
        let uid = data?["uid"] as? String
        let username = data?["username"] as? String
        
        remoteNotifySeatUpdate(avatar: avatar, pos: pos, uid: uid, username: username)
    }
    
    func remoteHandUpdate(documentSnapshot: DocumentSnapshot?, error: Error?) {
        guard let doc = documentSnapshot, doc.exists else {return}
        let data = doc.data()
        
        let payload = data?["payload"] as? [[String: Any]]
        let show = data?["show"] as? Bool
        let validCardIndices = data?["validCards"] as? [Int]
        let vibrate = data?["vibrate"] as? Int
        
        remoteNotifyHandUpdate(Hand.dictArrayToTuples(payload), show: show, validCardIndices: validCardIndices, vibrate: vibrate)
    }
    
    func remoteGameStartUpdate(documentSnapshot: DocumentSnapshot?, error: Error?) {
        guard let doc = documentSnapshot, doc.exists else {return}
        let data = doc.data()
        
        guard let isGameBegun = data?["isGameBegun"] as? Bool else {return}
        if let owner = Owner {
            if owner { return }
            self.isGameBegun = isGameBegun
        }
    }
    
    func remotePlayAttempt(documentSnapshot: DocumentSnapshot?, error: Error?) {
        guard let doc = documentSnapshot, doc.exists else {return}
        let data = doc.data()
        
        guard let playAttempt = data?["playAttempt"] as? [String: Int] else {return}
        guard let cardIndex = playAttempt["cardIndex"] else { return }
        guard let pos = playAttempt["pos"] else { return }
        if pos == truePlayerPosition { return }
        onPlayAttempt(cardIndex, playerIndex: pos.getRelPos(truePlayerPosition))
    }
    
    func remoteOptionsChoice(documentSnapshot: DocumentSnapshot?, error: Error?) {
        guard let doc = documentSnapshot, doc.exists else {return}
        let data = doc.data()
        
        guard let sourcePos = data?["sourcePos"] as? Int else { return }
        guard let stateName = data?["stateName"] as? String else { return }
        guard let pos = data?["pos"] as? Int else { return }
        if sourcePos == truePlayerPosition { return }
        if pos == truePlayerPosition { return }
        userGameStateChoice(StateName(rawValue: stateName))
    }
	
	
}

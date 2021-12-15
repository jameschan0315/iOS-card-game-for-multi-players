//
//  Firebase
//  All4s
//
//  Created by Adrian Bartholomew2 on 10/24/18.
//  Copyright © 2018 GB Soft. All rights reserved.
//

import Foundation
import Firebase

extension GameViewModel {
    
    func setStatesListener() {
        let ref = db.collection("rooms")
            .document(RoomId!)
            .collection("games")
            .document(GameId!)
            .collection("uiUpdates")
            .document("states")
            
        removeStatesListener = ref.addSnapshotListener { (documentSnapshot, error) in
            self.remoteStateUpdate(documentSnapshot: documentSnapshot, error: error)
        }
    }
    
    func setHandListener() {
        let ref = db.document("/rooms/\(RoomId!)/games/\(GameId!)/hands/hand\(truePlayerPosition)")
        removeHandListener = ref.addSnapshotListener { (documentSnapshot, error) in
            self.remoteHandUpdate(documentSnapshot: documentSnapshot, error: error)
        }
    }
    
    func setGameStartListener() {
        let ref = db.document("/rooms/\(RoomId!)/games/\(GameId!)")
        removeGameStartListener = ref.addSnapshotListener { (documentSnapshot, error) in
            self.remoteGameStartUpdate(documentSnapshot: documentSnapshot, error: error)
        }
    }

    func setPlayAttemptListener(_ set: Bool = true) {
        
        let ref = db.document("/rooms/\(RoomId!)/games/\(GameId!)")
        removePlayAttemptListener = ref.addSnapshotListener { (documentSnapshot, error) in
            self.remotePlayAttempt(documentSnapshot: documentSnapshot, error: error)
        }
    }

    func setOptionsChoicesListener() {
        let ref = db.document("/rooms/\(RoomId!)/games/\(GameId!)").collection("optionsChoices").document("latest")
        removeOptionsChoicesListener = ref.addSnapshotListener { (documentSnapshot, error) in
            self.remoteOptionsChoice(documentSnapshot: documentSnapshot, error: error)
        }
    }
	
}

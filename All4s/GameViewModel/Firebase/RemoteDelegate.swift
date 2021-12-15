//
//  delegates.swift
//  All4s Lite
//
//  Created by Adrian Bartholomew on 11/11/18.
//  Copyright © 2018 GB Soft. All rights reserved.
//

import Foundation


protocol RemoteDelegate: class {
    func broadcastStateAction(_ funcName: String, payload: [String: Any]?, selfNotify: Bool, broadcast: Bool)
    func animateDealing(dealAmt: Int)
    func showWinner()
}

extension GameViewModel: RemoteDelegate {
    
    func animateDealing(dealAmt: Int) {
        guard let pos = subGameController.getDealerPlayerPosition() else {return}
        let payload: [String: Any] = ["functionPosition": pos, "dealAmt": dealAmt]
        broadcastStateAction("animateDealing", payload: payload)
    }
    
    func showWinner() {
        print("showWinner")
        if game!.scores.points[0] > game!.scores.points[1] {
            broadcastStateAction("showWon", payload: nil)
        } else {
            broadcastStateAction("showLost", payload: nil)
        }
    }
    
    func setHandCallback(_ updateHandView: @escaping ([(String, Int)]) -> ()) {
        self.updateHandView = updateHandView
        game?.players.forEach{$0.setHandCallback() { (position: Int, cardTuples: [(String, Int)]) -> Void in
            
            if position == 0 {
                updateHandView(cardTuples)
                return
            }
            
            let dictArray = Hand.tuplesToDictArray(cardTuples)
            self.broadcastHandUpdate(dictArray, pos: position.getActualPos(self.truePlayerPosition))
        }}
    }
    
    func handRevealCallback(_ revealHandView: @escaping (Bool)->()) {
        self.revealHandView = revealHandView
        game?.players.forEach{$0.setRevealHandViewCallback() { (position: Int, show: Bool) -> Void in
            if position == 0 {
                revealHandView(show)
                return
            }
            
            self.broadcastHandUpdate(show, pos: position.getActualPos(self.truePlayerPosition))
        }}
    }
    
    func displayUser(_ user: [String: Any]) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "displayUser"), object: self, userInfo: user)
    }
    
    func
        eraseUser(_ pos: Int) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "eraseUser"), object: self, userInfo: ["pos": pos])
    }
    
    ///////////// Remote Notified by remote players //////////
    func remoteNotifyUI(_ dictionary: [String: Any]) {
        guard var payload = dictionary["payload"] as? [String: Any] else {return}
        let sourcePos = dictionary["sourcePos"] as? Int // May be irrelevant
        if isGameBegun && !Owner! && sourcePos != nil {
            if let functionPosition = payload["functionPosition"] as? Int {
                payload["functionPosition"] = functionPosition.getRelRemotePos(sourcePos: sourcePos!, truePos: truePlayerPosition)
            }
            payload["sourcePos"] = sourcePos // for scores to know the correct order
        }
        let funcName = dictionary["funcName"] as! String
        NotificationCenter.default.post(name: Notification.Name(rawValue: funcName), object: self, userInfo: payload)
    }
    
    func remoteNotifySeatUpdate(avatar: Int? = nil, pos: Int? = nil, uid: String? = nil, username: String? = nil) {
    }
    
    func remoteNotifyHandUpdate(_ payload: [(String, Int)]? = nil, show: Bool? = nil, validCardIndices: [Int]? = nil, vibrate: Int? = nil) {
        if Owner != nil && Owner! {return}
        if payload != nil {
            updateHandView?(payload!)
        }
        if show != nil {
            revealHandView?(show!)
        }
        if validCardIndices != nil {
            setValidCards(validCardIndices!)
        }
        if vibrate != nil {
            vibrateCard?(vibrate!)
        }
    }
    
//    func remoteNotifyGameUpdate(_ dictionary: [String: Any]) {
//        if Owner != nil && Owner! {return}
//        guard let payload = dictionary["payload"] as? [String: Any] else {return}
//        let funcName = dictionary["funcName"] as! String
//        if funcName == "isGameBegun" {
//            isGameBegun = payload["isGameBegun"] as! Bool
//        }
//    }
}

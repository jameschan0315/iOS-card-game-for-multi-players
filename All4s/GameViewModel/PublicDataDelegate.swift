//
//  PublicDataDelegate.swift
//  All4s
//
//  Created by Adrian Bartholomew on 11/12/18.
//  Copyright © 2018 GB Soft. All rights reserved.
//

import Foundation

protocol PublicDataDelegate: class {
    func myTurn() -> Bool
    func myPosition() -> Int
    func currPosition() -> Int?
    func dealerPosition() -> Int?
    func beggarPosition() -> Int?
    func currRound() -> Round?
    func getScores() -> Score // access from Scorable
    func getKick() -> Card?
    func getRounds() -> [Round]?
    func getTotalDealt() -> Int?
}

extension GameViewModel: PublicDataDelegate {
    
    func myTurn() -> Bool {
        guard let currPos = currPosition() else {return false}
        return game!.myPlayerPosition == currPos
    }
    
    func myPosition() -> Int {
        return 0
    }
    
    func currPosition() -> Int? {
        return subGameController.subGame?.currPosition
    }
    
    func dealerPosition() -> Int? {
        return subGameController.subGame?.dealerPlayerPosition
    }
    
    func beggarPosition() -> Int? {
        if let dealerPos = subGameController.subGame?.dealerPlayerPosition {
            return (dealerPos + 1) % 4
        }
        return nil
    }
    
    func currRound() -> Round? {
        return getRounds()?.last
    }
    
    func getKick() -> Card? {
        return subGameController.subGame?.kick
    }
    
    func getRounds() -> [Round]? {
        return subGameController.subGame?.rounds
    }
    
    func getTotalDealt() -> Int? {
        return subGameController.subGame?.totalDealt
    }
    
}

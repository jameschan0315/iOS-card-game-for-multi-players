//
//  Constants.swift
//  All4s
//
//  Created by Adrian Bartholomew on 11/22/18.
//  Copyright © 2018 GB Soft. All rights reserved.
//

import Foundation

class Constants {

    static private let WINNING_SCORE = 14
    static private let DEALER_POSITION: Int? = nil
    static private var TEST_REDEAL: Int = 0 // number of times
    static private var SAME_TRUMP: Int? = 0 // number of times

    static func getTestRedeal() -> Bool {
        let x = TEST_REDEAL > 0
        TEST_REDEAL -= 1
        return x
    }

    static func getTestSameTrump() -> Bool? {
        if SAME_TRUMP == nil { return nil }
        let x = SAME_TRUMP! > 0
        SAME_TRUMP? -= 1
        return x
    }

    static func getTestDealerPosition() -> Int? {
        return DEALER_POSITION
    }

    static func getWinningScore() -> Int {
        return WINNING_SCORE
    }

}

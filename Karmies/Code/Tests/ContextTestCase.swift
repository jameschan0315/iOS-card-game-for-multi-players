//
//  ContextTestCase.swift
//  Karmies
//
//  Created by Robert Nelson on 12/07/16.
//  Copyright © 2016 GB Soft. All rights reserved.
//

import XCTest
@testable import KarmiesTesting


class ContextTestCase: XCTestCase {

    func testGoogleAnalyticsTrackingID() {
        XCTAssertEqual(KarmiesContext.googleAnalyticsTrackingID, "UA-77165978-1") 
    }
    
}

//
//  ExtensionsTestCase.swift
//  Karmies
//
//  Created by Robert Nelson on 09/06/16.
//  Copyright © 2016 GB Soft. All rights reserved.
//

import XCTest
@testable import KarmiesTesting


class ExtensionsTestCase: XCTestCase {
    
    // MARK: URL
    
    func testFragmentParams() {
        let urls = [
            KarmiesAPI.joyURL(withParams: [("emoji", "smiley")]),
            KarmiesAPI.joyURL(withParams: [("emoji", "smiley"), ("payload", "")]),
            KarmiesAPI.joyURL(withParams: [("emoji", "corona"), ("payload", "m0nP6AMtiUMifaUULhVpGDzE5QsLkBrv~z7F1bVZgRWll97hcjeVaXH0RywLa5q6dWwhtbPbqYZqnpuU1Jjvt5VAZQdcTQXjb")]),
        ]
            
        urls.forEach {
            $0.krm_fragmentParams()
        }
    }
    
    func testEmptyPayload() {
        let params = KarmiesAPI.joyURL(withParams: [("emoji", "smiley"), ("payload", "")]).krm_fragmentParams()
        
        XCTAssertEqual(params["payload"], "")
    }
    
}

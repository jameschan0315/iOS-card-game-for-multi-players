//
//  BaseTestCase.swift
//  Karmies
//
//  Created by Robert Nelson on 15/07/16.
//  Copyright © 2016 GB Soft. All rights reserved.
//

import Foundation
import WebKit
import XCTest
@testable import KarmiesTesting


class BaseTestCase: XCTestCase {
    
    private(set) var context: KarmiesContext!
    var emojiStorage: EmojiStorage {
        return context.emojiStorage
    }
    
    override func setUp() {
        context = BaseTestCase.stubContext()
    }
    
    static func stubContext() -> KarmiesContext {
        let path = NSBundle(forClass: BaseTestCase.self).pathForResource("test_emoji_storage", ofType: "json")!
        let data = NSData(contentsOfFile: path)!
        let json = try! NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        return KarmiesContext.testing_instance(withPublisherID: "karmiegram", emojiStorageJson: json)
    }
    
}

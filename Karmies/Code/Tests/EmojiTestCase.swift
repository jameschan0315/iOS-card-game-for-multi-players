//
//  EmojiTestCase.swift
//  Karmies
//
//  Created by Robert Nelson on 14/06/16.
//  Copyright © 2016 GB Soft. All rights reserved.
//

import XCTest
@testable import KarmiesTesting


class EmojiTestCase: BaseTestCase {
    
    let token = "https://joy.karmies.com/#emoji=beers"
    
    // MARK: Tokens
    
    func testEmojiFromValidTokens() {
        let tokens = [
            KarmiesAPI.joyURL(withParams: [("emoji", "grin")]).absoluteString,
        ]
        
        tokens.forEach {
            XCTAssertNotNil(emojiStorage.emojiWithToken($0))
        }
    }
    
    func testEmojiFromInvalidTokens() {
        let tokens = [
            KarmiesAPI.joyURL(withParams: [("emoji", "dog?")]).absoluteString,
        ]
        
        tokens.forEach {
            XCTAssertNil(emojiStorage.emojiWithToken($0))
        }
    }
    
    func testEmojiFromTokensWithUnknownName() {
        let tokens = [
            KarmiesAPI.joyURL(withParams: [("emoji", "sunny_moon")]).absoluteString,
        ]
        
        tokens.forEach {
            XCTAssertNil(emojiStorage.emojiWithToken($0))
        }
    }
    
    // MARK: Messages
    
    func testDeserializeSimpleMessage() {
        let message = context.deserializeMessage("\(token)", outgoing: true)
        
        XCTAssertEqual(message.length, 1)
    }
    
    func testDeserializeComplexMessage() {
        let message = context.deserializeMessage("Hello  \(token)", outgoing: true)
        
        XCTAssertEqual(message.length, 7)
    }
    
    func testDeserializeMessageWithWhitespacePrefix() {
        let message = context.deserializeMessage("  \(token)", outgoing: true)
        
        XCTAssertEqual(message.length, 2)
    }
    
    func testDeserializeMessageWith2EmojisWithoutWhitespace() {
        let message1 = context.deserializeMessage("\(token)  \(token)", outgoing: true)
        let message2 = context.deserializeMessage("\(token) \(token)", outgoing: true)
        
        let length = 2
        XCTAssertEqual(message1.length, length)
        XCTAssertEqual(message2.length, length)
    }
    
    func testDeserializeMessageWith2EmojisWithWhitespace() {
        let message = context.deserializeMessage("\(token)   \(token)", outgoing: true)
        
        XCTAssertEqual(message.length, 3)
    }
    
    func testDeserializeMessageStartedWithEdgeWhitespaces() {
        let message1 = context.deserializeMessage(" \(token)", outgoing: true)
        let message2 = context.deserializeMessage("\(token) ", outgoing: true)
        let message3 = context.deserializeMessage(" \(token) ", outgoing: true)
        
        let length = 1
        XCTAssertEqual(message1.length, length)
        XCTAssertEqual(message2.length, length)
        XCTAssertEqual(message3.length, length)
    }
    
    func testDeserializeMessageWithoutEmojis() {
        let messages = [
            "\(token)\(token)",
            "http://joy.karmies.jp",
        ]
        
        messages.forEach {
            XCTAssertEqual(context.deserializeMessage($0, outgoing: true).length, $0.krm_length)
        }
    }
    
    func testSerializeMessage() {
        let originMessage = "\(token) \(token)"
        let message = context.serializeMessageFromAttributedString(context.deserializeMessage(originMessage, outgoing: true))
        
        XCTAssertEqual(message.krm_length, message.krm_trimmingWhitespaces().krm_length)
        XCTAssertEqual(message.krm_length, originMessage.krm_length + 1)
    }
    
    func testSerializeMessageWithWhitespacePrefix() {
        let originMessage = "  \(token)"
        let message = context.serializeMessageFromAttributedString(context.deserializeMessage(originMessage, outgoing: true))
        
        XCTAssertEqual(message.krm_length, originMessage.krm_length)
    }
    
    func testSerializedMessages() {
        let messages = [
            "\(token)",
            "\(token) bla",
            "bla \(token) bla",
        ]
        
        messages.forEach {
            XCTAssertTrue(context.isSerializedMessage($0))
        }
    }
    
    func testNonSerializedMessages() {
        let messages = [
            "\(token)\(token)",
            "http://joy.karmies.jp",
        ]
        
        messages.forEach {
            XCTAssertFalse(context.isSerializedMessage($0))
        }
    }
    
}

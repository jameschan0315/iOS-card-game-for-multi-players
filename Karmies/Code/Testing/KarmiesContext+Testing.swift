//
//  KarmiesContext+Testing.swift
//  Karmies
//
//  Created by Robert Nelson on 15/07/16.
//  Copyright © 2016 GB Soft. All rights reserved.
//

extension KarmiesContext {
    
    class func testing_instance(withPublisherID publisherID: String, emojiStorageJson json: AnyObject) -> KarmiesContext {
        let context = KarmiesContext(publisherID: publisherID)
        context.initEmojiStorage(withJson: json)
        return context
    }
    
}

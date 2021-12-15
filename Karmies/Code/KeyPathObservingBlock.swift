//
//  KeyPathObservingBlock.swift
//  Karmies
//
//  Created by Robert Nelson on 29/06/16.
//  Copyright © 2016 GB Soft. All rights reserved.
//

class KeyPathObservingBlock: NSObject {

    typealias ObserveHandler = (object: AnyObject?, change: [String: AnyObject]?) -> Void

    weak var object: NSObject?
    let keyPath: String
    let handler: ObserveHandler

    init(object: NSObject, keyPath: String, handler: ObserveHandler) {
        self.object = object
        self.keyPath = keyPath
        self.handler = handler
        super.init()

        object.addObserver(self, forKeyPath: keyPath, options: .New, context: nil)
    }

    deinit {
        object?.removeObserver(self, forKeyPath: keyPath)
    }

    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        handler(object: object, change: change)
    }

}
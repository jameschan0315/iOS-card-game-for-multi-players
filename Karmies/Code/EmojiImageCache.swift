//
//  EmojiImageCache.swift
//  Karmies
//
//  Created by Robert Nelson on 14/06/16.
//  Copyright © 2016 GB Soft. All rights reserved.
//

class EmojiImageCache {
    
    typealias CompletionHandler = (UIImage?) -> Void
    
    private let operationQueue = EmojiImageCache.createOperatioQueue()
    private var cache = SimpleImageCache(temporaryDirectoryName: "karmiesEmojiCache")
    
    func imageForPath(path: String) -> UIImage? {
        if let image = cache[path] {
            return image
        }
        else {
            if let data = NSData(contentsOfURL: KarmiesAPI.grimacingURLForPath(path)) {
                let image = UIImage(data: data)
                cache[path] = image
                return image
            }
            return nil
        }
    }
    
    func asyncImageForPath(path: String, completionHandler: CompletionHandler) {
        if let image = cache[path] {
            completionHandler(image)
        }
        else {
            operationQueue.addOperationWithBlock { [unowned self] in
                let image = self.imageForPath(path)
                dispatch_sync(dispatch_get_main_queue()) {
                    completionHandler(image)
                }
            }
        }
    }
    
    private class func createOperatioQueue() -> NSOperationQueue {
        let operationQueue = NSOperationQueue()
        operationQueue.maxConcurrentOperationCount = 10
        if #available(iOS 8.0, *) {
            operationQueue.qualityOfService = NSQualityOfService.Background
        }
        return operationQueue
    }
    
}
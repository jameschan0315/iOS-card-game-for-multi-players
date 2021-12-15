//
//  SimpleImageCache.swift
//  Karmies
//
//  Created by Robert Nelson on 29/06/16.
//  Copyright © 2016 GB Soft. All rights reserved.
//

class SimpleImageCache {

    let temporaryDirectoryPath: String

    var cache = [String: UIImage]()

    init(temporaryDirectoryName name: String) {
        temporaryDirectoryPath = NSTemporaryDirectory() + name

        try! NSFileManager.defaultManager().createDirectoryAtPath(temporaryDirectoryPath, withIntermediateDirectories: true, attributes: nil)
    }

    subscript(key: String) -> UIImage? {
        get {
            if let image = cache[key] {
                return image
            }
            else if let image = loadImageForKey(key) {
                cache[key] = image
                return image
            }
            return nil
        }
        set(image) {
            cache[key] = image
            saveImage(image!, withKey: key)
        }
    }

    private func loadImageForKey(key: String) -> UIImage? {
        let path = pathForKey(key)
        if let data = NSData(contentsOfFile: path) {
            return UIImage(data: data)
        }
        return nil
    }

    private func saveImage(image: UIImage, withKey key: String) {
        let data = UIImagePNGRepresentation(image)!
        data.writeToFile(pathForKey(key), atomically: false)
    }

    private func pathForKey(key: String) -> String {
        return temporaryDirectoryPath + key.stringByReplacingOccurrencesOfString("/", withString: "_")
    }

}
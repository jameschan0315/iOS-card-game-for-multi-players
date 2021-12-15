//
//  KarmiesAPI.swift
//  Karmies
//
//  Created by Robert Nelson on 21/06/16.
//  Copyright © 2016 GB Soft. All rights reserved.
//


class KarmiesAPI {
    
    private static let grimacingURLString = "https://grimacing.karmies.com/"
    private static let grimacingCategoriesURLString = KarmiesAPI.grimacingURLString + "categories/"
    static let joyPrefixURLString = "https://joy.karmies.com/"
    
    static func grimacingCategoriesURL(withClientID clientID: String, params: [(String, String)] = []) -> NSURL {
        let urlString = KarmiesAPI.grimacingCategoriesURLString + clientID + "?" + params.map { "\($0)=\($1)" }.joinWithSeparator("&")
        let url = NSURL(string: urlString)
        if url == nil {
            karmiesLog("fail with \(clientID) | urlString=\(urlString)")
        }

        karmiesURLLog(url!)
        return url!
    }
    
    static func grimacingURLForPath(path: String) -> NSURL {
        let urlString = grimacingURLString + path
        let url = NSURL(string: urlString)
        if url == nil {
            karmiesLog("fail with \(path) | urlString=\(urlString)")
        }

        karmiesURLLog(url!)
        return url!
    }
    
    static func joyURL(withParams params: [(String, String)]) -> NSURL {
        let urlString = joyPrefixURLString + "#" + params.map { "\($0)=\($1)" }.joinWithSeparator("&")
        let url = NSURL(string: urlString)
        if url == nil {
            karmiesLog("fail with \(params) | urlString=\(urlString)")
        }

        karmiesURLLog(url!)
        return url!
    }
    
}

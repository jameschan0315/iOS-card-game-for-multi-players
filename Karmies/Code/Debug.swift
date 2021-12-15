//
//  Debug.swift
//  Karmies
//
//  Created by Robert Nelson on 29/06/16.
//  Copyright © 2016 GB Soft. All rights reserved.
//

func karmiesLog(@autoclosure text: () -> String, funcName: StaticString = #function) {
    #if !NDEBUG
        print("\(NSDate()) Karmies { \(funcName): \(text()) }")
    #endif
}

func karmiesURLLog(@autoclosure url: () -> NSURL) {
    #if !NDEBUG
        print("\(NSDate()) Karmies { using URL: \(url()) }")
    #endif
}
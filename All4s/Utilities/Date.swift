//
//  Date.swift
//  All4s
//
//  Created by Adrian Bartholomew on 12/30/18.
//  Copyright © 2018 GB Soft. All rights reserved.
//

import Foundation

extension Date {
    func currentTimeMillis() -> Int64! {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}

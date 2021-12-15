//
//  WeakWrapper.swift
//  Karmies
//
//  Created by Robert Nelson on 16/06/16.
//  Copyright © 2016 GB Soft. All rights reserved.
//

class WeakWrapper<T: AnyObject> {
    
    weak var value: T?
    
    init(value: T) {
        self.value = value
    }

}


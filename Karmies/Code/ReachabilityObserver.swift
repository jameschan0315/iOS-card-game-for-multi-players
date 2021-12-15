//
//  ReachabilityObserver.swift
//  Karmies
//
//  Created by Robert Nelson on 18/07/16.
//  Copyright © 2016 GB Soft. All rights reserved.
//

import SystemConfiguration


func krm_reachabilityCallback(reachability: SCNetworkReachability, flags: SCNetworkReachabilityFlags, info: UnsafeMutablePointer<Void>) {
    let observer = Unmanaged<ReachabilityObserver>.fromOpaque(COpaquePointer(info)).takeUnretainedValue()
    
    dispatch_async(dispatch_get_main_queue()) {
        observer.reachabilityWasChanged(flags)
    }
}


class ReachabilityObserver: NSObject {
    
    static let ReachabilityWasChangedNotificationName = "ReachabilityObserver.ReachabilityWasChangedNotification"
    
    private static let dispatchQueue = dispatch_queue_create(KarmiesContext.bundleIdentifier + ".ReachabilityObserver.dispatchQueue", DISPATCH_QUEUE_SERIAL)
    
    private let reachabilityRef: SCNetworkReachability
    
    private var previousReachabilityFlags: SCNetworkReachabilityFlags?
    private var reachabilityFlags: SCNetworkReachabilityFlags {
        var flags = SCNetworkReachabilityFlags()
        let isValid = withUnsafeMutablePointer(&flags) {
            SCNetworkReachabilityGetFlags(reachabilityRef, UnsafeMutablePointer($0))
        }
        
        return (isValid) ? flags : SCNetworkReachabilityFlags()
    }
    
    private var running = false
    
    var isReachable: Bool {
        return reachabilityFlags.contains(.Reachable)
    }
    
    init(url: NSURL) {
        let nodename = (url.host! as NSString).UTF8String
        reachabilityRef = SCNetworkReachabilityCreateWithName(nil, nodename)!
        
        super.init()
        
        start()
    }
    
    deinit {
        stop()
    }
    
    func start() {
        guard !running else {
            return
        }
        running = true
        
        var context = SCNetworkReachabilityContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
        context.info = UnsafeMutablePointer(Unmanaged.passUnretained(self).toOpaque())
        
        if !SCNetworkReachabilitySetCallback(reachabilityRef, krm_reachabilityCallback, &context) {
            karmiesLog("unable to set callbak!")
            
            stop()
        }
        
        if !SCNetworkReachabilitySetDispatchQueue(reachabilityRef, ReachabilityObserver.dispatchQueue) {
            karmiesLog("unable to set dispatch queue")
            
            stop()
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            self.reachabilityWasChanged(self.reachabilityFlags)
        }
    }
    
    func stop() {
        guard running else {
            return
        }
        
        SCNetworkReachabilitySetCallback(reachabilityRef, nil, nil)
        SCNetworkReachabilitySetDispatchQueue(reachabilityRef, nil)
        
        running = false
    }
    
    private func reachabilityWasChanged(flags: SCNetworkReachabilityFlags) {
        guard previousReachabilityFlags != flags else {
            return
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(ReachabilityObserver.ReachabilityWasChangedNotificationName, object:self)
        
        previousReachabilityFlags = flags
    }
}

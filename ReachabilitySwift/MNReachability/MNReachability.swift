//
//  MNReachability.swift
//  ReachabilitySwift
//
//  Created by mosn on 2/25/16.
//  Copyright © 2016 com.*. All rights reserved.
//

import Foundation
import UIKit

public enum ReachabilityStatus: Int {
    case ReachStatusNotReachable = 0
    case ReachStatusViaWWAN = 1
    case ReachStatusViaWiFi = 2
}

let kRealReachabilityChangedNotification = "kRealReachabilityChangedNotification"

let kDefaultHost = "www.baidu.com"
let kDefaultCheckInterval = 1.0

public class MNReachability {
    static let sharedInstance = MNReachability()
    
    var hostForPing:String = kDefaultHost
    var autoCheckInterval:Double = kDefaultCheckInterval
    var isNotifying:Bool = false
    
    init() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appBecomeActive", name:UIApplicationDidBecomeActiveNotification, object: nil)
    }
    
    
    public func startNotifier() {
        
    }
    
    public func stopNotifier() {
        
    }
    
    public func reachabilityWithBlock(asyncHandler:(ReachabilityStatus)->Void) {
        
       
    }
    
    public func currentReachabilityStatus() -> ReachabilityStatus {
        return .ReachStatusNotReachable
    }
    
    func appBecomeActive() {
        if self.isNotifying {
            reachabilityWithBlock({
                Void -> Void in
            })
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        stopNotifier()
    }
    
}
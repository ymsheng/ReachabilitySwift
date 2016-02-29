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

public class MNReachability:NSObject {
    static let sharedInstance = MNReachability()
    
    var engine:FSMEngine
    var hostForPing:String = kDefaultHost
    var autoCheckInterval:Double = kDefaultCheckInterval
    var isNotifying:Bool = false
    
    override init() {
        self.engine = FSMEngine()
        self.engine.start()
        
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appBecomeActive", name:UIApplicationDidBecomeActiveNotification, object: nil)
    }
    
    
    public func startNotifier() {
        if self.isNotifying {
            return
        }
        self.isNotifying = true
        
        self.engine.reciveInput([kEventKeyID:NSNumber(integer:RREventID.RREventLoad.rawValue)])
        
        LocalConnection.shareInstance.startNotifier()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "localConnectionChanged:", name: kLocalConnectionChangedNotification, object: nil)
        
    }
    
    public func stopNotifier() {
        self.engine.reciveInput([kEventKeyID:NSNumber(integer: RREventID.RREventUnLoad.rawValue)])
        LocalConnection.shareInstance.stopNotifier()
        self.isNotifying = false
    }
    
    public func reachabilityWithBlock(asyncHandler:((ReachabilityStatus)->Void)) {
        
        
    }
    
    public func currentReachabilityStatus() -> ReachabilityStatus {
        let currentID:RRStateID = self.engine.currentStateID
        switch currentID {
        case RRStateID.RRStateUnReachable:
            return .ReachStatusNotReachable
        case RRStateID.RRStateWIFI:
            return .ReachStatusViaWiFi
        case RRStateID.RRStateWWAN:
            return .ReachStatusViaWWAN
        case RRStateID.RRStateLoading:
            return ReachabilityStatus(rawValue:LocalConnection.shareInstance.currentLocalConnectionStatus().rawValue)!
        default:
            return .ReachStatusNotReachable
        }
        
    }
    
    public func paramValueFromStatus(status:LocalConnectionStatus) -> String {
        switch status {
        case .LC_UnReachable:
            return kParamValueUnReachable
        case .LC_WiFi:
            return kParamValueWIFI
        case .LC_WWAN:
            return kParamValueWWAN
        }
    }
    
    func appBecomeActive() {
        if self.isNotifying {
            self.reachabilityWithBlock({
                Void -> Void in
            })
        }
    }
    
    func localConnectionChanged(notification:NSNotification) {
        let lc:LocalConnection = notification.object as! LocalConnection
        let lcStatus:LocalConnectionStatus = lc.currentLocalConnectionStatus()
        let rtn = self.engine.reciveInput([kEventKeyID:NSNumber(integer: RREventID.RREventLocalConnectionCallback.rawValue),kEventKeyParam:self.paramValueFromStatus(lcStatus)])
        if rtn == 0 {
            if self.engine.isCurrentStateAvailable() {
                NSNotificationCenter.defaultCenter().postNotificationName(kRealReachabilityChangedNotification, object: self)
                //                self.reachabilityWithBlock(asyncHandler:nil)
            }
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        LocalConnection.shareInstance.stopNotifier()
    }
    
}
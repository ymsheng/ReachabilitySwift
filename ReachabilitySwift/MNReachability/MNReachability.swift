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

let kDefaultHost = "http://www.baidu.com"
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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appBecomeActive", name:UIApplicationWillEnterForegroundNotification, object: nil)
    }
    
    
    public func startNotifier() {
        if self.isNotifying {
            return
        }
        self.isNotifying = true
        
        self.engine.reciveInput([kEventKeyID:NSNumber(integer:RREventID.RREventLoad.rawValue)])
        
        LocalConnection.shareInstance.startNotifier()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "localConnectionChanged:", name: kLocalConnectionChangedNotification, object: nil)
        
        PingHelper.shareInstance.setHost(self.hostForPing)
        
        self.autoCheckReachability()
    }
    
    public func stopNotifier() {
        self.engine.reciveInput([kEventKeyID:NSNumber(integer: RREventID.RREventUnLoad.rawValue)])
        LocalConnection.shareInstance.stopNotifier()
        self.isNotifying = false
    }
    
    public func reachabilityWithBlock(asyncHandler:((ReachabilityStatus)->Void)?) {
        weak var weakSelf = self as MNReachability
        PingHelper.shareInstance.pingWithBlock({ (isSuccess) -> Void in
            let rtn = weakSelf?.engine.reciveInput([kEventKeyID:NSNumber(integer: RREventID.RREventPingCallback.rawValue),kEventKeyParam:NSNumber(bool: isSuccess)])
            if rtn == 0 {
                if ((weakSelf?.engine.isCurrentStateAvailable()) != nil) {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        NSNotificationCenter.defaultCenter().postNotificationName(kRealReachabilityChangedNotification, object: weakSelf)
                    })
                }
            }
            if asyncHandler != nil {
                let currentID:RRStateID = (weakSelf?.engine.currentStateID)!
                switch currentID {
                case RRStateID.RRStateUnReachable:
                    asyncHandler!(ReachabilityStatus.ReachStatusNotReachable)
                case RRStateID.RRStateWIFI:
                    asyncHandler!(ReachabilityStatus.ReachStatusViaWiFi)
                case RRStateID.RRStateWWAN:
                    asyncHandler!(ReachabilityStatus.ReachStatusViaWWAN)
                default:
                    asyncHandler!(ReachabilityStatus.ReachStatusNotReachable)
                }
            }
        })
        
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
            self.reachabilityWithBlock(nil)
        }
    }
    
    func localConnectionChanged(notification:NSNotification) {
        let lc:LocalConnection = notification.object as! LocalConnection
        let lcStatus:LocalConnectionStatus = lc.currentLocalConnectionStatus()
        let rtn = self.engine.reciveInput([kEventKeyID:NSNumber(integer: RREventID.RREventLocalConnectionCallback.rawValue),kEventKeyParam:self.paramValueFromStatus(lcStatus)])
        if rtn == 0 {
            if self.engine.isCurrentStateAvailable() {
                NSNotificationCenter.defaultCenter().postNotificationName(kRealReachabilityChangedNotification, object: self)
                reachabilityWithBlock(nil);
            }
        }
    }
    
    func autoCheckReachability() {
        if self.isNotifying == false {
            return
        }
        
        weak var weakSelf = self as MNReachability
        let popTime = dispatch_time(DISPATCH_TIME_NOW,
            Int64(60 * self.autoCheckInterval * Double(NSEC_PER_SEC))) // 1
        dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            weakSelf?.reachabilityWithBlock(nil);
            weakSelf?.autoCheckReachability()
        })
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        LocalConnection.shareInstance.stopNotifier()
    }
    
}
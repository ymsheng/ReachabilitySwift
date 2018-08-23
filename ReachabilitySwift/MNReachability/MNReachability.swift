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
    case reachStatusNotReachable = 0
    case reachStatusViaWWAN = 1
    case reachStatusViaWiFi = 2
}

public let kRealReachabilityChangedNotification = "kRealReachabilityChangedNotification"

let kDefaultHost = "http://www.baidu.com"
let kDefaultCheckInterval = 1.0

open class MNReachability:NSObject {
    open static let sharedInstance = MNReachability()
    
    var engine:FSMEngine
    var hostForPing:String = kDefaultHost
    var autoCheckInterval:Double = kDefaultCheckInterval
    var isNotifying:Bool = false
    
    override init() {
        self.engine = FSMEngine()
        self.engine.start()
        
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(MNReachability.appBecomeActive), name:NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    
    open func startNotifier() {
        if self.isNotifying {
            return
        }
        self.isNotifying = true
        
        self.engine.reciveInput([kEventKeyID:NSNumber(value: RREventID.rrEventLoad.rawValue as Int)])
        
        LocalConnection.shareInstance.startNotifier()
        
        NotificationCenter.default.addObserver(self, selector: #selector(MNReachability.localConnectionChanged(_:)), name: NSNotification.Name(rawValue: kLocalConnectionChangedNotification), object: nil)
        
        PingHelper.shareInstance.setHost(self.hostForPing)
        
        self.autoCheckReachability()
    }
    
    open func stopNotifier() {
        self.engine.reciveInput([kEventKeyID:NSNumber(value: RREventID.rrEventUnLoad.rawValue as Int)])
        LocalConnection.shareInstance.stopNotifier()
        self.isNotifying = false
    }
    
    open func reachabilityWithBlock(_ asyncHandler:((ReachabilityStatus)->Void)?) {
        weak var weakSelf = self as MNReachability
        PingHelper.shareInstance.pingWithBlock({ (isSuccess) -> Void in
            let rtn = weakSelf?.engine.reciveInput([kEventKeyID:NSNumber(value: RREventID.rrEventPingCallback.rawValue as Int),kEventKeyParam:NSNumber(value: isSuccess as Bool)])
            if rtn == 0 {
                if ((weakSelf?.engine.isCurrentStateAvailable()) != nil) {
                    DispatchQueue.main.async(execute: { () -> Void in
                        NotificationCenter.default.post(name: Notification.Name(rawValue: kRealReachabilityChangedNotification), object: weakSelf)
                    })
                }
            }
            if asyncHandler != nil {
                let currentID:RRStateID = (weakSelf?.engine.currentStateID)!
                switch currentID {
                case RRStateID.rrStateUnReachable:
                    asyncHandler!(ReachabilityStatus.reachStatusNotReachable)
                case RRStateID.rrStateWIFI:
                    asyncHandler!(ReachabilityStatus.reachStatusViaWiFi)
                case RRStateID.rrStateWWAN:
                    asyncHandler!(ReachabilityStatus.reachStatusViaWWAN)
                default:
                    asyncHandler!(ReachabilityStatus.reachStatusNotReachable)
                }
            }
        })
        
    }
    
    open func currentReachabilityStatus() -> ReachabilityStatus {
        let currentID:RRStateID = self.engine.currentStateID
        switch currentID {
        case RRStateID.rrStateUnReachable:
            return .reachStatusNotReachable
        case RRStateID.rrStateWIFI:
            return .reachStatusViaWiFi
        case RRStateID.rrStateWWAN:
            return .reachStatusViaWWAN
        case RRStateID.rrStateLoading:
            return ReachabilityStatus(rawValue:LocalConnection.shareInstance.currentLocalConnectionStatus().rawValue)!
        default:
            return .reachStatusNotReachable
        }
        
    }
    
    open func paramValueFromStatus(_ status:LocalConnectionStatus) -> String {
        switch status {
        case .lc_UnReachable:
            return kParamValueUnReachable
        case .lc_WiFi:
            return kParamValueWIFI
        case .lc_WWAN:
            return kParamValueWWAN
        }
    }
    
    @objc func appBecomeActive() {
        if self.isNotifying {
            self.reachabilityWithBlock(nil)
        }
    }
    
    @objc func localConnectionChanged(_ notification:Notification) {
        let lc:LocalConnection = notification.object as! LocalConnection
        let lcStatus:LocalConnectionStatus = lc.currentLocalConnectionStatus()
        let rtn = self.engine.reciveInput([kEventKeyID:NSNumber(value: RREventID.rrEventLocalConnectionCallback.rawValue as Int),kEventKeyParam:self.paramValueFromStatus(lcStatus)])
        if rtn == 0 {
            if self.engine.isCurrentStateAvailable() {
                NotificationCenter.default.post(name: Notification.Name(rawValue: kRealReachabilityChangedNotification), object: self)
                reachabilityWithBlock(nil);
            }
        }
    }
    
    func autoCheckReachability() {
        if self.isNotifying == false {
            return
        }
        
        weak var weakSelf = self as MNReachability
        let popTime = DispatchTime.now() + Double(Int64(60 * self.autoCheckInterval * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC) // 1
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).asyncAfter(deadline: popTime, execute: { () -> Void in
            weakSelf?.reachabilityWithBlock(nil);
            weakSelf?.autoCheckReachability()
        })
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        LocalConnection.shareInstance.stopNotifier()
    }
    
}

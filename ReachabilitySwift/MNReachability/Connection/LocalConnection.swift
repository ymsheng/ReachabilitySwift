//
//  LocalConnection.swift
//  ReachabilitySwift
//
//  Created by mosn on 2/25/16.
//  Copyright © 2016 com.*. All rights reserved.
//

import Foundation

import SystemConfiguration

public enum LocalConnectionStatus:Int {
    case lc_UnReachable = 0
    case lc_WWAN = 1
    case lc_WiFi = 2
}

let kLocalConnectionChangedNotification = "kLocalConnectionChangedNotification"

public func LocalConnectionCallback(_ target:SCNetworkReachability, flags:SCNetworkReachabilityFlags, info:AnyObject) {
    let connection = info as! LocalConnection
    autoreleasepool { () -> () in
        connection.localConnectionChanged()
    }
}

public func connectionFlags(_ flags:SCNetworkReachabilityFlags) -> String {
    return String(format: "%s%s %s%s%s%s%s%s%s",((flags.rawValue & SCNetworkReachabilityFlags.isWWAN.rawValue != 0) ? "W" : "-"),
        ((flags.rawValue & SCNetworkReachabilityFlags.reachable.rawValue != 0) ? "R" : "-"),
        ((flags.rawValue & SCNetworkReachabilityFlags.connectionRequired.rawValue != 0) ? "c" : "-"),
        ((flags.rawValue & SCNetworkReachabilityFlags.transientConnection.rawValue != 0) ? "t" : "-"),
        ((flags.rawValue & SCNetworkReachabilityFlags.interventionRequired.rawValue != 0) ? "i" : "-"),
        ((flags.rawValue & SCNetworkReachabilityFlags.connectionOnTraffic.rawValue != 0) ? "C" : "-"),
        ((flags.rawValue & SCNetworkReachabilityFlags.connectionOnDemand.rawValue != 0) ? "D" : "-"),
        ((flags.rawValue & SCNetworkReachabilityFlags.isLocalAddress.rawValue != 0) ? "l" : "-"),
        ((flags.rawValue & SCNetworkReachabilityFlags.isDirect.rawValue != 0) ? "d" : "-"))
}

open class LocalConnection : NSObject {
    static let shareInstance = LocalConnection()
    var reachabilityRef:SCNetworkReachability
    var reachabilitySerialQueue:DispatchQueue
    
    override init(){
        var zeroAddr = sockaddr(sa_len: 0, sa_family: 0, sa_data: (0,0,0,0,0,0,0,0,0,0,0,0,0,0))
        zeroAddr.sa_len = UInt8(MemoryLayout.size(ofValue: zeroAddr))
        zeroAddr.sa_family = sa_family_t(AF_INET)
        
        self.reachabilityRef = SCNetworkReachabilityCreateWithAddress(nil, &zeroAddr)!
        self.reachabilitySerialQueue = DispatchQueue(label: "com.dlnu.reachabilityswift", attributes: [])
    }
    
    open func startNotifier() {
      
        var context = SCNetworkReachabilityContext(version: 0, info: unsafeBitCast(self, to: UnsafeMutablePointer<Int>.self), retain: nil, release: nil, copyDescription: nil)
        
        if SCNetworkReachabilitySetCallback(self.reachabilityRef, {(_,_,info) in
            let connection = unsafeBitCast(info, to: LocalConnection.self)
            autoreleasepool { () -> () in
                connection.localConnectionChanged()
            }
            } , &context) != false{//&context
                
                print("设置回调成功");
                
                if SCNetworkReachabilitySetDispatchQueue(self.reachabilityRef, self.reachabilitySerialQueue) == false
                {
                    SCNetworkReachabilitySetCallback(self.reachabilityRef, nil, nil)
                    print("设置runloop fail")
                }
        }
        else {
            print("SCNetworkReachabilitySetCallback() failed: \(SCErrorString(SCError()))");
        }
        
        localConnectionChanged()
        
    }
    
    open func stopNotifier() {
        SCNetworkReachabilitySetCallback(self.reachabilityRef, nil, nil)
        SCNetworkReachabilitySetDispatchQueue(self.reachabilityRef, nil)
    }
    
    open func currentLocalConnectionStatus() -> LocalConnectionStatus {
        if self.isReachable() {
            if self.isReachableViaWifi() {
                return .lc_WiFi
            }
            else {
                return .lc_WWAN
            }
        }
        else{
            return .lc_UnReachable
        }
    }
    
    open func localConnectionChanged() {
        DispatchQueue.main.async(execute: { () -> Void in
            NotificationCenter.default.post(name: Notification.Name(rawValue: kLocalConnectionChangedNotification), object: self)
        })
    }
    
    func isReachable() -> Bool {
        var flags:SCNetworkReachabilityFlags = SCNetworkReachabilityFlags.isDirect
        if SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags) == false {
            return false
        }
        else {
            return self.isReachableWithFlags(flags)
        }
    }
    
    func isReachableWithFlags(_ flags:SCNetworkReachabilityFlags) -> Bool {
        if (flags.rawValue & SCNetworkReachabilityFlags.reachable.rawValue) == 0 {
            return false
        }
        if (flags.rawValue & SCNetworkReachabilityFlags.connectionRequired.rawValue) == 0 {
            return true
        }
        if (flags.rawValue & SCNetworkReachabilityFlags.connectionOnDemand.rawValue) != 0 ||
            (flags.rawValue & SCNetworkReachabilityFlags.connectionOnTraffic.rawValue) != 0 {
                if (flags.rawValue & SCNetworkReachabilityFlags.interventionRequired.rawValue) == 0 {
                    return true
                }
        }
        return false
    }
    
    func isReachableViaWWAN() -> Bool {
        var flags:SCNetworkReachabilityFlags = SCNetworkReachabilityFlags.transientConnection
        if SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags) {
            if (flags.rawValue & SCNetworkReachabilityFlags.reachable.rawValue) != 0 {
                if (flags.rawValue & SCNetworkReachabilityFlags.isWWAN.rawValue)  != 0 {
                    return true
                }
            }
        }
        
        return false
    }
    func isReachableViaWifi() -> Bool {
        var flags:SCNetworkReachabilityFlags = SCNetworkReachabilityFlags.transientConnection
        if SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags) {
            if (flags.rawValue & SCNetworkReachabilityFlags.reachable.rawValue)  != 0 {
                if (flags.rawValue & SCNetworkReachabilityFlags.isWWAN.rawValue)  != 0 {
                    return false
                }
                return true
            }
        }
        
        return false
    }
    
    
    
    
    deinit {
        stopNotifier()
        
    }
}

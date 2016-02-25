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
    case LC_UnReachable = 0
    case LC_WWAN = 1
    case LC_WiFi = 2
}

let kLocalConnectionChangedNotification = "kLocalConnectionChangedNotification"

public func LocalConnectionCallback(target:SCNetworkReachabilityRef, flags:SCNetworkReachabilityFlags, info:AnyObject) {
    let connection = info as! LocalConnection
    autoreleasepool { () -> () in
        connection.localConnectionChanged()
    }
}

public func connectionFlags(flags:SCNetworkReachabilityFlags) -> String {
    return String(format: "%s%s %s%s%s%s%s%s%s",((flags.rawValue & SCNetworkReachabilityFlags.IsWWAN.rawValue != 0) ? "W" : "-"),
        ((flags.rawValue & SCNetworkReachabilityFlags.Reachable.rawValue != 0) ? "R" : "-"),
        ((flags.rawValue & SCNetworkReachabilityFlags.ConnectionRequired.rawValue != 0) ? "c" : "-"),
        ((flags.rawValue & SCNetworkReachabilityFlags.TransientConnection.rawValue != 0) ? "t" : "-"),
        ((flags.rawValue & SCNetworkReachabilityFlags.InterventionRequired.rawValue != 0) ? "i" : "-"),
        ((flags.rawValue & SCNetworkReachabilityFlags.ConnectionOnTraffic.rawValue != 0) ? "C" : "-"),
        ((flags.rawValue & SCNetworkReachabilityFlags.ConnectionOnDemand.rawValue != 0) ? "D" : "-"),
        ((flags.rawValue & SCNetworkReachabilityFlags.IsLocalAddress.rawValue != 0) ? "l" : "-"),
        ((flags.rawValue & SCNetworkReachabilityFlags.IsDirect.rawValue != 0) ? "d" : "-"))
}

public class LocalConnection {
    static let shareInstance = LocalConnection()
    var reachabilityRef:SCNetworkReachabilityRef
    var reachabilitySerialQueue:dispatch_queue_t
    
    init(){
        var zeroAddr = sockaddr(sa_len: 0, sa_family: 0, sa_data: (0,0,0,0,0,0,0,0,0,0,0,0,0,0))
        zeroAddr.sa_len = UInt8(sizeofValue(zeroAddr))
        zeroAddr.sa_family = sa_family_t(AF_INET)
        
        self.reachabilityRef = SCNetworkReachabilityCreateWithAddress(nil, &zeroAddr)!
        self.reachabilitySerialQueue = dispatch_queue_create("com.dlnu.reachabilityswift", nil)
    }
    
    public func startNotifier() {
        //        let block: @convention(block) (SCNetworkReachabilityRef, SCNetworkReachabilityFlags, UnsafePointer<Void>) -> Void = {
        ////            let connection = info as! LocalConnection
        ////            autoreleasepool { () -> () in
        ////                connection.localConnectionChanged()
        ////            }
        //        }
        //
        //
        //        let blockObject = imp_implementationWithBlock(unsafeBitCast(block, AnyObject.self))
        //        let fp = unsafeBitCast(blockObject, SCNetworkReachabilityCallBack.self)
        
        
        if SCNetworkReachabilitySetCallback(self.reachabilityRef, {(_,_,info) in
            let connection = unsafeBitCast(info, LocalConnection.self)
            autoreleasepool { () -> () in
                connection.localConnectionChanged()
            }
            } , nil) != false{//&context
                
                print("设置回调成功");
                
                if !SCNetworkReachabilitySetDispatchQueue(self.reachabilityRef, self.reachabilitySerialQueue)
                {
                    SCNetworkReachabilitySetCallback(self.reachabilityRef, nil, nil)
                    print("设置runloop成功")
                }
        }
        else {
            print("SCNetworkReachabilitySetCallback() failed: \(SCErrorString(SCError()))");
        }
        
        localConnectionChanged()
        
    }
    
    public func stopNotifier() {
        SCNetworkReachabilitySetCallback(self.reachabilityRef, nil, nil)
        SCNetworkReachabilitySetDispatchQueue(self.reachabilityRef, nil)
    }
    
    public func currentLocalConnectionStatus() -> LocalConnectionStatus {
        return .LC_UnReachable
    }
    
    public func localConnectionChanged() -> LocalConnectionStatus {
        if self.isReachable() {
            if self.isReachableViaWifi() {
                return .LC_WiFi
            }
            else {
                return .LC_WWAN
            }
        }
        else{
            return .LC_UnReachable
        }
    }
    
    func isReachable() -> Bool {
        var flags:SCNetworkReachabilityFlags = SCNetworkReachabilityFlags.IsDirect
        if SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags) {
            return false
        }
        else {
            return self.isReachableWithFlags(flags)
        }
    }
    
    func isReachableWithFlags(flags:SCNetworkReachabilityFlags) -> Bool {
        if (flags.rawValue & SCNetworkReachabilityFlags.Reachable.rawValue) == 0 {
            return false
        }
        if (flags.rawValue & SCNetworkReachabilityFlags.ConnectionRequired.rawValue) == 0 {
            return true
        }
        if (flags.rawValue & SCNetworkReachabilityFlags.ConnectionOnDemand.rawValue) != 0 ||
            (flags.rawValue & SCNetworkReachabilityFlags.ConnectionOnTraffic.rawValue) != 0 {
                if (flags.rawValue & SCNetworkReachabilityFlags.InterventionRequired.rawValue) == 0 {
                    return true
                }
        }
        return false
    }
    
    func isReachableViaWWAN() -> Bool {
        var flags:SCNetworkReachabilityFlags = SCNetworkReachabilityFlags.TransientConnection
        if SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags) {
            if (flags.rawValue & SCNetworkReachabilityFlags.Reachable.rawValue) == 1 {
                if (flags.rawValue & SCNetworkReachabilityFlags.IsWWAN.rawValue) == 1 {
                    return true
                }
            }
        }
        
        return false
    }
    func isReachableViaWifi() -> Bool {
        var flags:SCNetworkReachabilityFlags = SCNetworkReachabilityFlags.TransientConnection
        if SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags) {
            if (flags.rawValue & SCNetworkReachabilityFlags.Reachable.rawValue) == 1 {
                if (flags.rawValue & SCNetworkReachabilityFlags.IsWWAN.rawValue) == 1 {
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
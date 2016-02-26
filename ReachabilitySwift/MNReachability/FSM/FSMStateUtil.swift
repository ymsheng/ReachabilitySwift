//
//  FSMStateUtil.swift
//  ReachabilitySwift
//
//  Created by mosn on 2/25/16.
//  Copyright © 2016 com.*. All rights reserved.
//

import Foundation


public class FSMStateUtil {
    static public func RRStateFromValue(LCEventValue:String) -> RRStateID {
        if LCEventValue == kParamValueUnReachable {
            return RRStateID.RRStateUnReachable
        }
        else if LCEventValue == kParamValueWWAN {
            return RRStateID.RRStateWWAN
        }
        else if LCEventValue == kParamValueWIFI {
            return RRStateID.RRStateWIFI
        }
        else {
            return RRStateID.RRStateInvalid
        }
    }
    
    static public func RRStateFromPingFlag(isSuccess:Bool) -> RRStateID {
        let status:LocalConnectionStatus = LocalConnection.shareInstance.currentLocalConnectionStatus()
        
        if !isSuccess {
            return RRStateID.RRStateUnReachable
        }
        else{
            switch status {
            case .LC_UnReachable:
                return RRStateID.RRStateUnReachable
            case .LC_WiFi:
                return RRStateID.RRStateWIFI
            case .LC_WWAN:
                return RRStateID.RRStateWWAN
                
            }
//            return RRStateID.RRStateWIFI
        }
    }
}
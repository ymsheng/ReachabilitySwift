//
//  FSMStateUtil.swift
//  ReachabilitySwift
//
//  Created by mosn on 2/25/16.
//  Copyright © 2016 com.*. All rights reserved.
//

import Foundation


open class FSMStateUtil {
    static open func RRStateFromValue(_ LCEventValue:String) -> RRStateID {
        if LCEventValue == kParamValueUnReachable {
            return RRStateID.rrStateUnReachable
        }
        else if LCEventValue == kParamValueWWAN {
            return RRStateID.rrStateWWAN
        }
        else if LCEventValue == kParamValueWIFI {
            return RRStateID.rrStateWIFI
        }
        else {
            return RRStateID.rrStateInvalid
        }
    }
    
    static open func RRStateFromPingFlag(_ isSuccess:Bool) -> RRStateID {
        let status:LocalConnectionStatus = LocalConnection.shareInstance.currentLocalConnectionStatus()
        
        if !isSuccess {
            return RRStateID.rrStateUnReachable
        }
        else{
            switch status {
            case .lc_UnReachable:
                return RRStateID.rrStateUnReachable
            case .lc_WiFi:
                return RRStateID.rrStateWIFI
            case .lc_WWAN:
                return RRStateID.rrStateWWAN
                
            }
//            return RRStateID.RRStateWIFI
        }
    }
}

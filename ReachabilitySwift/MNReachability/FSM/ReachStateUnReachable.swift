//
//  ReachStateUnReachable.swift
//  ReachabilitySwift
//
//  Created by mosn on 2/25/16.
//  Copyright © 2016 com.*. All rights reserved.
//

import Foundation

open class ReachStateUnReachable:ReachState {
    override open func onEventWithError(_ event: NSDictionary) throws -> RRStateID {
        var resStateID = RRStateID.rrStateUnReachable
        let eventID = Int((event[kEventKeyID] as! Int))
        
        switch eventID {
        case RREventID.rrEventUnLoad.rawValue:
            resStateID = RRStateID.rrStateUnloaded
        case RREventID.rrEventPingCallback.rawValue:
            let eventParam = (event[kEventKeyParam]! as AnyObject).boolValue
            resStateID = FSMStateUtil.RRStateFromPingFlag(eventParam!)
        case RREventID.rrEventLocalConnectionCallback.rawValue:
            resStateID = FSMStateUtil.RRStateFromValue(event[kEventKeyParam] as! String)
        default:
            throw NSError(domain: "FSM", code: kFSMErrorNotAccept, userInfo: nil)
        }
        
        return resStateID;
    }
}

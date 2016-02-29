//
//  ReachStateUnReachable.swift
//  ReachabilitySwift
//
//  Created by mosn on 2/25/16.
//  Copyright © 2016 com.*. All rights reserved.
//

import Foundation

public class ReachStateUnReachable:ReachState {
    override public func onEventWithError(event: NSDictionary) throws -> RRStateID {
        var resStateID = RRStateID.RRStateUnReachable
        let eventID = Int(event[kEventKeyID]!.integerValue)
        
        switch eventID {
        case RREventID.RREventUnLoad.rawValue:
            resStateID = RRStateID.RRStateUnloaded
        case RREventID.RREventPingCallback.rawValue:
            let eventParam = event[kEventKeyParam]!.boolValue
            resStateID = FSMStateUtil.RRStateFromPingFlag(eventParam)
        case RREventID.RREventLocalConnectionCallback.rawValue:
            resStateID = FSMStateUtil.RRStateFromValue(event[kEventKeyParam] as! String)
        default:
            throw NSError(domain: "FSM", code: kFSMErrorNotAccept, userInfo: nil)
        }
        
        return resStateID;
    }
}
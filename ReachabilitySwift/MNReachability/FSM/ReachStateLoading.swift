//
//  ReachStateLoading.swift
//  ReachabilitySwift
//
//  Created by mosn on 2/25/16.
//  Copyright © 2016 com.*. All rights reserved.
//

import Foundation

public class ReachStateLoading:ReachState {
    
    override public func onEventWithError(event: NSDictionary) throws -> RRStateID {
        var resStateID = RRStateID.RRStateLoading
        let eventID = Int(event[kEventKeyID]!.integerValue)

        switch eventID {
        case RREventID.RREventUnLoad.rawValue:
            resStateID = RRStateID.RRStateUnloaded
        case RREventID.RREventPingCallback.rawValue:
            let eventParam = event[kEventKeyParam]!.boolValue
            resStateID = FSMStateUtil.RRStateFromPingFlag(eventParam)
        case RREventID.RREventLocalConnectionCallback.rawValue:
            resStateID = FSMStateUtil.RRStateFromValue(event[kEventKeyParam]!.string)
        default:
            throw NSError(domain: "FSM", code: kFSMErrorNotAccept, userInfo: nil)
        }
        
        return resStateID;
    }
}
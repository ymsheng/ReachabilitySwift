//
//  ReachStateUnloaded.swift
//  ReachabilitySwift
//
//  Created by mosn on 2/25/16.
//  Copyright © 2016 com.*. All rights reserved.
//

import Foundation

public class ReachStateUnloaded:ReachState {
    override public func onEventWithError(event: NSDictionary) throws -> RRStateID {
        var resStateID:RRStateID = RRStateID.RRStateUnloaded
        let eventID = Int(event[kEventKeyID]!.integerValue)
        
        switch eventID {
        case RREventID.RREventLoad.rawValue:
            resStateID = RRStateID.RRStateLoading
        default:
            throw NSError(domain: "FSM", code: kFSMErrorNotAccept, userInfo: nil)
        }
        
        return resStateID;
    }
}
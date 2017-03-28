//
//  ReachStateUnloaded.swift
//  ReachabilitySwift
//
//  Created by mosn on 2/25/16.
//  Copyright © 2016 com.*. All rights reserved.
//

import Foundation

open class ReachStateUnloaded:ReachState {
    override open func onEventWithError(_ event: NSDictionary) throws -> RRStateID {
        var resStateID:RRStateID = RRStateID.rrStateUnloaded
        let eventID = Int((event[kEventKeyID] as! Int))
        
        switch eventID {
        case RREventID.rrEventLoad.rawValue:
            resStateID = RRStateID.rrStateLoading
        default:
            throw NSError(domain: "FSM", code: kFSMErrorNotAccept, userInfo: nil)
        }
        
        return resStateID;
    }
}

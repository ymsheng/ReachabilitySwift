//
//  ReachState.swift
//  ReachabilitySwift
//
//  Created by mosn on 2/25/16.
//  Copyright © 2016 com.*. All rights reserved.
//

import Foundation

public class ReachState {
    public func onEventWithError(event:NSDictionary) throws -> RRStateID {
        return RRStateID.RRStateInvalid
    }
}
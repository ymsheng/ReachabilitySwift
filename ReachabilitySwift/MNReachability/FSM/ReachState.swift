//
//  ReachState.swift
//  ReachabilitySwift
//
//  Created by mosn on 2/25/16.
//  Copyright © 2016 com.*. All rights reserved.
//

import Foundation

open class ReachState {
    open func onEventWithError(_ event:NSDictionary) throws -> RRStateID {
        return RRStateID.rrStateInvalid
    }
}

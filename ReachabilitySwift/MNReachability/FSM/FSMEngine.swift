//
//  FSMEngine.swift
//  ReachabilitySwift
//
//  Created by mosn on 2/25/16.
//  Copyright © 2016 com.*. All rights reserved.
//

import Foundation

let kEventKeyID = "event_id"
let kEventKeyParam = "event_param"
let kParamValueUnReachable = "ParamValueUnReachable"
let kParamValueWWAN = "ParamValueWWAN"
let kParamValueWIFI = "ParamValueWIFI"

let kFSMErrorNotAccept = 13

public enum RRStateID:Int {
    case rrStateInvalid = -1
    case rrStateUnloaded = 0
    case rrStateLoading = 1
    case rrStateUnReachable = 2
    case rrStateWIFI = 3
    case rrStateWWAN = 4
}

public enum RREventID:Int {
    case rrEventLoad = 0
    case rrEventUnLoad = 1
    case rrEventLocalConnectionCallback = 2
    case rrEventPingCallback = 3
}


open class FSMEngine {
    var currentStateID:RRStateID = .rrStateInvalid
    var allStatus:NSArray = [ReachStateUnloaded(),ReachStateUnReachable(),ReachStateLoading(),ReachStateWIFI(),ReachStateWWAN()]
    
    init() {
        
    }
    
    open func start() {
        self.currentStateID = .rrStateUnloaded
    }
    
    open func reciveInput(_ dic:NSDictionary) -> Int {

        let currentState:ReachState = self.allStatus[self.currentStateID.rawValue] as! ReachState
        var previousStateID:RRStateID =  self.currentStateID
        
        do {
            let newStateID:RRStateID = try currentState.onEventWithError(dic)
           
            previousStateID = self.currentStateID
            self.currentStateID = newStateID
            
            
        }catch {
               print("onEvent error\(error)")
        }
        
        return (previousStateID == self.currentStateID) ? -1:0
        
        
    }
    
    open func isCurrentStateAvailable() -> Bool {
        if self.currentStateID.rawValue == RRStateID.rrStateUnReachable.rawValue ||
        self.currentStateID.rawValue == RRStateID.rrStateWWAN.rawValue ||
        self.currentStateID.rawValue == RRStateID.rrStateWIFI.rawValue {
            return true
        }
        else{
            return false
        }
    }
    
    deinit {
//        self.allStatus = nil
    }
}

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
    case RRStateInvalid = -1
    case RRStateUnloaded = 0
    case RRStateLoading = 1
    case RRStateUnReachable = 2
    case RRStateWIFI = 3
    case RRStateWWAN = 4
}

public enum RREventID:Int {
    case RREventLoad = 0
    case RREventUnLoad = 1
    case RREventLocalConnectionCallback = 2
    case RREventPingCallback = 3
}


public class FSMEngine {
    var currentStateID:RRStateID = .RRStateInvalid
    var allStatus:NSArray = [ReachStateUnloaded(),ReachStateUnReachable(),ReachStateLoading(),ReachStateWIFI(),ReachStateWWAN()]
    
    init() {
        
    }
    
    public func start() {
        self.currentStateID = .RRStateUnloaded
    }
    
    public func reciveInput(dic:NSDictionary) -> Int {

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
    
    public func isCurrentStateAvailable() -> Bool {
        if self.currentStateID.rawValue == RRStateID.RRStateUnReachable.rawValue ||
        self.currentStateID.rawValue == RRStateID.RRStateWWAN.rawValue ||
        self.currentStateID.rawValue == RRStateID.RRStateWIFI.rawValue {
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
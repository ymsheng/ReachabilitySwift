//
//  PingHelper.swift
//  ReachabilitySwift
//
//  Created by mosn on 2/25/16.
//  Copyright © 2016 com.*. All rights reserved.
//

import Foundation

let kPingResultNotification = "kPingResultNotification"

public typealias comBlock = (Bool) -> Void

public class PingHelper : PingFoundationDelegate {
    static let shareInstance = PingHelper()
    
    var completionBlocks:NSMutableArray = NSMutableArray()
    var pingFoundation:PingFoundation?
    var isPinging:Bool = false

    
    public func pingWithBlock(completion:comBlock) {
        self.completionBlocks.addObject(completion as! AnyObject)
        
        if self.isPinging == false {
            self.pingFoundation!.stop()
            weak var weakSelf = self as PingHelper
            dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                weakSelf?.isPinging = true
                weakSelf?.pingFoundation!.start()
                
                dispatch_after(2, dispatch_get_main_queue(), { () -> Void in
                    weakSelf?.endWithFlag(false)
                })
            })
        }
    }
    
    func setHost(host:String) {
        self.pingFoundation = PingFoundation.pingFoundationWithHostName(host)
        self.pingFoundation!.delegate = self
    }
    
    
    func endWithFlag(isSuccess:Bool) {
        if self.isPinging == false {
            return
        }
        
        self.isPinging = false
        self.pingFoundation?.stop()
        
        
        for(var i=0;i<self.completionBlocks.count;i++) {
            let block:comBlock = self.completionBlocks.objectAtIndex(i) as! comBlock
            block(isSuccess)
        }
        
        self.completionBlocks.removeAllObjects()
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName(kPingResultNotification, object: NSNumber(bool: isSuccess))
        }
    }
    
    //MARK: - pingfoundation delegate
    @objc public func pingFoundationDidStartWithAddress(pinger:PingFoundation, address:NSData) {

    }
    @objc public func pingFoundationDidFailWithError(pinger:PingFoundation, error:NSError) {
        self.endWithFlag(false)
    }
    @objc public func pingFoundationDidSendPacket(pinger:PingFoundation, packet:NSData) {
        
    }
    @objc public func pingFoundationDidFailToSendPacketWithError(pinger:PingFoundation, packet:NSData, error:NSError) {
         self.endWithFlag(false)
    }
    @objc public func pingFoundationDidReceivePingResponsePacket(pinger:PingFoundation, packet:NSData) {
         self.endWithFlag(false)
    }
    @objc public func pingFoundationDidReceiveUnexpectedPacket(ping:PingFoundation, packet:NSData) {
        
    }
    
    deinit {
        self.completionBlocks.removeAllObjects()
    }
}
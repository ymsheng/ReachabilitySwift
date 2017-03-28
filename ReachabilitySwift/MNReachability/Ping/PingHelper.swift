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

open class PingHelper : PingFoundationDelegate {
    static let shareInstance = PingHelper()
    
    var completionBlock:comBlock?
    var pingFoundation:PingFoundation?
    var isPinging:Bool = false
    
    
    open func pingWithBlock(_ completion:@escaping comBlock) {
        
        if self.isPinging == false {
            self.completionBlock = completion
            self.pingFoundation!.stop()
            weak var weakSelf = self as PingHelper
            DispatchQueue.main.async(execute: { () -> Void in
                weakSelf?.isPinging = true
                weakSelf?.pingFoundation!.start()
                
                let popTime = DispatchTime.now() + Double(Int64(2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC) 
                DispatchQueue.main.asyncAfter(deadline: popTime, execute: { () -> Void in
                    weakSelf?.endWithFlag(false)
                })
            })
        }
    }
    
    func setHost(_ host:String) {
        self.pingFoundation = PingFoundation.pingFoundationWithHostName(host)
        self.pingFoundation!.delegate = self
    }
    
    
    func endWithFlag(_ isSuccess:Bool) {
//        if self.isPinging == false {
//            return
//        }
        
        self.isPinging = false
        self.pingFoundation?.stop()
        
        if self.completionBlock != nil {
            self.completionBlock!(isSuccess)
        }
        
        self.completionBlock = nil
        
        DispatchQueue.main.async { () -> Void in
            NotificationCenter.default.post(name: Notification.Name(rawValue: kPingResultNotification), object: NSNumber(value: isSuccess as Bool))
        }
    }
    
    //MARK: - pingfoundation delegate
    @objc open func pingFoundationDidStartWithAddress(_ pinger:PingFoundation, address:Data) {
        
    }
    @objc open func pingFoundationDidFailWithError(_ pinger:PingFoundation, error:NSError) {
        self.endWithFlag(false)
    }
    @objc open func pingFoundationDidSendPacket(_ pinger:PingFoundation, packet:Data) {
        
    }
    @objc open func pingFoundationDidFailToSendPacketWithError(_ pinger:PingFoundation, packet:Data, error:NSError) {
        self.endWithFlag(false)
    }
    @objc open func pingFoundationDidReceivePingResponsePacket(_ pinger:PingFoundation, packet:Data) {
        self.endWithFlag(true)
    }
    @objc open func pingFoundationDidReceiveUnexpectedPacket(_ ping:PingFoundation, packet:Data) {
        
    }
    
    deinit {
        self.completionBlock = nil
    }
}

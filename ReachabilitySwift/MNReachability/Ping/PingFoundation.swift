//
//  PingFoundation.swift
//  ReachabilitySwift
//
//  Created by mosn on 2/25/16.
//  Copyright © 2016 com.*. All rights reserved.
//

import Foundation
import CFNetwork


struct IPHeader {
    let versionAndHeaderLength:Int
    let differentiatedServices:Int
    let totalLength:Int
    let identification:Int
    let flagsAndFragmentOffset:Int
    let timeToLive:Int
    let protocolf:Int
    let headerChecksum:Int
    let sourceAddress:[Int]
    let destinationAddress:[Int]

}

struct ICMPHeader {
    let type:Int
    let code:Int
    let checksum:Int
    let identifier:Int
    let sequenceNumber:Int
}

enum kICMPType:Int {
    case kICMPTypeEchoReply = 0
    case kICMPTypeEchoRequest = 8
}

@objc public protocol PingFoundationDelegate {
    optional func pingFoundationDidStartWithAddress(pinger:PingFoundation, address:NSData)
    optional func pingFoundationDidFailWithError(pinger:PingFoundation, error:NSError)
    optional func pingFoundationDidSendPacket(pinger:PingFoundation, packet:NSData)
    optional func pingFoundationDidFailToSendPacketWithError(pinger:PingFoundation, packet:NSData, error:NSError)
    optional func pingFoundationDidReceivePingResponsePacket(pinger:PingFoundation, packet:NSData)
    optional func pingFoundationDidReceiveUnexpectedPacket(ping:PingFoundation, packet:NSData)
}

@objc public class PingFoundation : NSObject {
    var delegate:PingFoundationDelegate?
    var hostName:String?
    var hostAddress:NSData?
    var identifier:Int
    var nextSequenceNumber:Int
    
    
    init(hostName:String?, hostAddress:NSData?) {
        self.hostName = hostName
        self.hostAddress = hostAddress
        self.identifier = random()
        self.nextSequenceNumber = 0
    }
    
    public func start() {
        
    }
    
    public func stop() {
        
    }
    
    func sendPingWithData(data:NSData) {
        
    }
    
    func icmpInPacket(packet:NSData) -> ICMPHeader? {
        return nil
    }
    
    func didFailWithError(error:NSError) {
        self.stop()
        self.delegate?.pingFoundationDidFailWithError!(self, error: error)
    }
    
    func didFailWithHostStreamError(streamError:CFStreamError) {
        self.didFailWithError(NSError(domain: (kCFErrorDomainCFNetwork as String), code:2, userInfo: nil))
    }
    
   
    //MARK: - static init
    static public func pingFoundationWithHostName(hostName:String) -> PingFoundation {
        return PingFoundation(hostName: hostName, hostAddress: nil)
    }
    
    static public func pingFoundationWithHostAddress(hostAddress:NSData) -> PingFoundation {
        return PingFoundation(hostName: nil, hostAddress: hostAddress)
    }
}
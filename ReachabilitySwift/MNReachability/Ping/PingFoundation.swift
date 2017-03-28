//
//  PingFoundation.swift
//  ReachabilitySwift
//
//  Created by mosn on 2/25/16.
//  Copyright © 2016 com.*. All rights reserved.
//

import Foundation
import CFNetwork
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}



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
    @objc optional func pingFoundationDidStartWithAddress(_ pinger:PingFoundation, address:Data)
    @objc optional func pingFoundationDidFailWithError(_ pinger:PingFoundation, error:NSError)
    @objc optional func pingFoundationDidSendPacket(_ pinger:PingFoundation, packet:Data)
    @objc optional func pingFoundationDidFailToSendPacketWithError(_ pinger:PingFoundation, packet:Data, error:NSError)
    @objc optional func pingFoundationDidReceivePingResponsePacket(_ pinger:PingFoundation, packet:Data)
    @objc optional func pingFoundationDidReceiveUnexpectedPacket(_ ping:PingFoundation, packet:Data)
}

@objc open class PingFoundation : NSObject {
    var delegate:PingFoundationDelegate?
    var hostName:String?
    var hostAddress:Data?
    var identifier:Int
    var nextSequenceNumber:Int
    var task:URLSessionDataTask?
    
    init(hostName:String?, hostAddress:Data?) {
        self.hostName = hostName
        self.hostAddress = hostAddress
        self.identifier = Int(arc4random())
        self.nextSequenceNumber = 0
    }
    
    open func start() {
        if self.task != nil {
            self.task!.cancel()
        }
        
        weak var weakSelf = self as PingFoundation
        
        self.task = URLSession.shared.dataTask(with: URLRequest(url: URL(string: self.hostName!)!), completionHandler: { (data,response,error) -> Void in
            
            if error != nil {
                weakSelf?.delegate?.pingFoundationDidFailWithError!(weakSelf!, error: error! as NSError)
            }
            else if data?.count > 1 {
                weakSelf?.delegate?.pingFoundationDidReceivePingResponsePacket!(weakSelf!, packet: data!)
            }
            else {
                weakSelf?.delegate?.pingFoundationDidFailToSendPacketWithError!(weakSelf!, packet: data!, error: error! as NSError)
            }
        })
        
        task?.resume()
    }
    
    open func stop() {
        if self.task != nil {
            self.task!.cancel()
        }
    }
    
    func sendPingWithData(_ data:Data) {
        
    }
    
    func icmpInPacket(_ packet:Data) -> ICMPHeader? {
        return nil
    }
    
    func didFailWithError(_ error:NSError) {
        self.stop()
        self.delegate?.pingFoundationDidFailWithError!(self, error: error)
    }
    
    func didFailWithHostStreamError(_ streamError:CFStreamError) {
        self.didFailWithError(NSError(domain: (kCFErrorDomainCFNetwork as String), code:2, userInfo: nil))
    }
    
  
   
    //MARK: - static init
    static open func pingFoundationWithHostName(_ hostName:String) -> PingFoundation {
        return PingFoundation(hostName: hostName, hostAddress: nil)
    }
    
    static open func pingFoundationWithHostAddress(_ hostAddress:Data) -> PingFoundation {
        return PingFoundation(hostName: nil, hostAddress: hostAddress)
    }
}

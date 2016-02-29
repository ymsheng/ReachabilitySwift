//
//  ViewController.swift
//  ReachabilitySwift
//
//  Created by mosn on 2/25/16.
//  Copyright © 2016 com.*. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var lbMessage:UILabel?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MNReachability.sharedInstance.startNotifier()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "networkChanged:", name: kRealReachabilityChangedNotification, object: nil)
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func networkChanged(notification:NSNotification) {
        let reachability:MNReachability = notification.object as! MNReachability
        let status:ReachabilityStatus = reachability.currentReachabilityStatus()
        
        if status == ReachabilityStatus.ReachStatusNotReachable {
            self.lbMessage?.text = "network unreachable"
        }
        else if status == ReachabilityStatus.ReachStatusViaWiFi {
            self.lbMessage?.text =  "network wifi! Free"
        }
        else if status == ReachabilityStatus.ReachStatusViaWWAN {
            self.lbMessage?.text = "network WWAN! In charge"
        }
    }
    
    @IBAction func clickAction() {
        MNReachability.sharedInstance.reachabilityWithBlock { (status) -> Void in
            switch status {
            case .ReachStatusNotReachable:
                print("Nothing to do! offlineMode")
            case .ReachStatusViaWiFi:
                print("WIFI you get! free")
            case .ReachStatusViaWWAN:
                print("take care of your moeny")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}


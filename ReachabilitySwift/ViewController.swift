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
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.networkChanged(_:)), name: NSNotification.Name(rawValue: kRealReachabilityChangedNotification), object: nil)
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @objc func networkChanged(_ notification:Notification) {
        let reachability:MNReachability = notification.object as! MNReachability
        let status:ReachabilityStatus = reachability.currentReachabilityStatus()
        
        if status == ReachabilityStatus.reachStatusNotReachable {
            self.lbMessage?.text = "network unreachable"
        }
        else if status == ReachabilityStatus.reachStatusViaWiFi {
            self.lbMessage?.text =  "network wifi! Free"
        }
        else if status == ReachabilityStatus.reachStatusViaWWAN {
            self.lbMessage?.text = "network WWAN! In charge"
        }
    }
    
    @IBAction func clickAction() {
        MNReachability.sharedInstance.reachabilityWithBlock { (status) -> Void in
            switch status {
            case .reachStatusNotReachable:
                print("Nothing to do! offlineMode")
            case .reachStatusViaWiFi:
                print("WIFI you get! free")
            case .reachStatusViaWWAN:
                print("take care of your moeny")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}


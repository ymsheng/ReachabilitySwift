# MNReachabilitySwift

#### We need to abserve the Real reachability of network for iOS. But Reachability only check your device is connect by wifi or wwan, MNReachabilitySwift do the real jobs.
Apple doc tells us something about SCNetworkReachability API: "Note that reachability does not guarantee that the data packet will actually be received by the host."
##### MNReachabilitySwift contains two step:
1. check your device connect by wifi or wwan
2. try connect to "www.baidu.com" and judge if the server has response

## How To User:
import MNReachabilitySwift
MNReachability.sharedInstance.startNotifier()   //start test
NSNotificationCenter.defaultCenter().addObserver(self, selector: "networkChanged:", name: kRealReachabilityChangedNotification, object: nil)
func networkChanged(notification:NSNotification) {
        let reachability:MNReachability = notification.object as! MNReachability
        let status:ReachabilityStatus = reachability.currentReachabilityStatus()
        
        if status == ReachabilityStatus.ReachStatusNotReachable {
            print("network unreachable")
        }
        else if status == ReachabilityStatus.ReachStatusViaWiFi {
            print("network wifi! Free")
        }
        else if status == ReachabilityStatus.ReachStatusViaWWAN {
            print("network WWAN! In charge")
        }
    }
    
## Quick Start With Cocoapods
1.Use Code Direct
  Download the project, add swift file in MNReachability to your project.
  
2.Use CocoaPods Install
   
   platform :ios, "8.0"
   
   use_frameworks!
   
   pod 'MNReachabilitySwift', '~> 0.0.2'
   

了解CocoaPods
http://ymsheng.github.io/cocoapods.html

//
//  AppDelegate.swift
//  AVPlayerDemo
//
//  Created by carry on 2022/2/28.
//

import UIKit


@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        BZXCDEService.activate()
        
        DispatchQueue.main.async {
            self.startService()
//            self.getDNS()
        }
        return true
    }
    
    private func getDNS() {
        let domainName = "sv.nintyinc.com"
        let host = CFHostCreateWithName(nil,domainName as CFString).takeRetainedValue()
        CFHostStartInfoResolution(host, .addresses, nil)
        var success: DarwinBoolean = false

        var dnsAddress: [String] = []
        if let addresses = CFHostGetAddressing(host, &success)?.takeUnretainedValue() as NSArray? {
            for case let theAddress as NSData in addresses {
                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                if getnameinfo(theAddress.bytes.assumingMemoryBound(to: sockaddr.self), socklen_t(theAddress.length),
                               &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 {
                    let numAddress = String(cString: hostname)
                    
                    dnsAddress.append(numAddress)
                }
            }
        }
        
        let alert = UIAlertController(title: "DNS ip", message: dnsAddress.joined(separator: "\n"), preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(ok)
        window?.rootViewController?.present(alert, animated: true, completion: nil)
    }

    private func startService() {
        print("start CDE")
        let p = BZXCDEService.startParserService()
        if (p > 0) {
            print("start CDE ok")
            if let vc = (window?.rootViewController as? UINavigationController)?.topViewController as? ViewController {
                vc.p2pButton.isEnabled = true
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.startService()
            }
        }
    }

}


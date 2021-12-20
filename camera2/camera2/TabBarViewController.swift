//
//  TabBarViewController.swift
//  camera2
//
//  Created by Данила Ярмаркин on 09.12.2021.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true

        let server = Server()
        server.monitoringData()
        
        Server.registerDevice()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(enterBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(enterBackground),
                                               name: UIApplication.didFinishLaunchingNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(enterFocus),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }
    
    @objc func enterBackground() {
        Server.unregisterDevice()
    }
    
    @objc func enterFocus() {
        Server.registerDevice()
    }
    
    
    
}

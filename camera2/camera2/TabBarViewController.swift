//
//  TabBarViewController.swift
//  camera2
//
//  Created by Данила Ярмаркин on 09.12.2021.
//

import UIKit
import MetricKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true
        
        let metricManager = MXMetricManager.shared
        metricManager.add(self)

        let server = Server()
        server.updateDeviceStatus()
        
        UIDevice.current.isBatteryMonitoringEnabled = true
        
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
        
    }
    
    @objc func enterFocus() {
        
    }
    
    
    
}


extension TabBarViewController: MXMetricManagerSubscriber {
    func didReceive(_ payloads: [MXMetricPayload]) {
      guard let firstPayload = payloads.first else { return }
      print(firstPayload.dictionaryRepresentation())
    }

    func didReceive(_ payloads: [MXDiagnosticPayload]) {
      guard let firstPayload = payloads.first else { return }
      print(firstPayload.dictionaryRepresentation())
    }
}

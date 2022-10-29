//
//  DeviceStatusTableView.swift
//  camera2
//
//  Created by Данила Ярмаркин on 20.12.2021.
//

import UIKit
import Firebase

class DeviceStatusTableView: UITableView{
    
    
    var devices = [ConnectionDevice]()
    
    var ref: DatabaseReference!
    
    func configure() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateDevices(_:)), name: NSNotification.Name(DevicesData.devicesDataKey), object: nil)
    }
    
    @objc func updateDevices(_ notification: Notification) {
        let info = notification.userInfo as? [String: Any] ?? [:]
        devices = info["value"] as! [ConnectionDevice]
        self.reloadData()
    }
}

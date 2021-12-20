//
//  DeviceStatusTableView.swift
//  camera2
//
//  Created by Данила Ярмаркин on 20.12.2021.
//

import UIKit
import Firebase

class DeviceStatusTableView: UITableView{
    
    
    var activeDevices: [String] = []
    var batteryData: Dictionary<String, Int> = [:]
    var storageData: Dictionary<String, Int> = [:]
    var totalStorageData: Dictionary<String, Int> = [:]
    
    var ref: DatabaseReference!
    
    func configure() {
        ref = Database.database(url: Server.firebasePath).reference()
        
        let server = Server()
        server.updateDeviceStatus()
        
        ref.child("devices").observe(.value, with: {(snapshot) in
            let value = snapshot.value
            if let val = value as? Dictionary<String, Int> {
                self.activeDevices = []
                for device in val {
                    if device.value as! Int != 0 {
                        self.activeDevices.append(device.key)
                    }
                }
                self.reloadData()
                print("reload")
            }
        })
        
        ref.child("batteryData").observe(.value, with: {(snapshot) in
            let value = snapshot.value
            if let val = value as? Dictionary<String, Int> {
                self.batteryData = val
                self.reloadData()
            }
        })
        ref.child("storageData").observe(.value, with: {(snapshot) in
            let value = snapshot.value
            if let val = value as? Dictionary<String, Int> {
                self.storageData = val
                self.reloadData()
            }
        })
        ref.child("totalStorageData").observe(.value, with: {(snapshot) in
            let value = snapshot.value
            if let val = value as? Dictionary<String, Int> {
                self.totalStorageData = val
                self.reloadData()
            }
        })
    }
}

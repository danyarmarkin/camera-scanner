//
//  BatteryControl.swift
//  camera
//
//  Created by Данила Ярмаркин on 17.07.2021.
//

import Foundation
import UIKit
import Firebase

class BatteryControl {
    static var activeDevices: [String] = []
    static var batteryData: Dictionary<String, Float> = [:]
    
    static func control(label: UILabel, ref: DatabaseReference) {
        print("battery data monitoring...")
        print(UIDevice.current.isBatteryMonitoringEnabled)
        UIDevice.current.isBatteryMonitoringEnabled = true
        ref.child("batteryData").child(LocalStorage.getString(key: LocalStorage.deviceName)).setValue(UIDevice.current.batteryLevel)
        ref.child("batteryData").observe(.value, with: {(snapshot) in
            let value = snapshot.value
            print("new battery data: \(value ?? 0)")
            if let val = value as? Dictionary<String, Float> {
                self.batteryData = val
                update()
            }
        })
        
        ref.child("devices").observe(.value, with: {(snapshot) in
            let value = snapshot.value
            if let val = value as? Dictionary<String, Int> {
                self.activeDevices = []
                for device in val {
                    if device.value as! Int != 0 {
                        self.activeDevices.append(device.key)
                    }
                }
                update()
            }
        })
        
        func update() {
            label.text = ""
            for device in activeDevices {
                if batteryData.keys.contains(device) {
                    label.text! += "\n\(device) \(batteryData[device] as! Float * 100)%"
                }
            } 
        }
    }
    
}

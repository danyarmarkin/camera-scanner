//
//  deviceControl.swift
//  camera
//
//  Created by Данила Ярмаркин on 28.06.2021.
//

import Foundation
import Firebase

class DeviceControl {
    var ref: DatabaseReference!
    
    var devices: [String] = []
    
    func configure(ref: DatabaseReference) {
        self.ref = ref
    }
    
    func monitorDevices() {
        
    }
    
    func registerDevice() {
        self.ref.child("devices").child(LocalStorage.getString(key: LocalStorage.deviceName)).setValue(1)
    }
    
    func unregisterDevice() {
        self.ref.child("devices").child(LocalStorage.getString(key: LocalStorage.deviceName)).setValue(0)
    }
}

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
        let updateParam = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: {(timer) in
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy"
            let result = formatter.string(from: date)
            self.ref.child("date").setValue(result)
        })
        updateParam.tolerance = 5
        
        ref.child("devices").observe(DataEventType.value, with: {(snapshot) in
            if LocalStorage.getBool(key: LocalStorage.isMainDevice) {
                let value = snapshot.value
                print("changed")
                if let val = value as? Dictionary<String, Int> {
                    let sortedKeys = Array(val.keys).sorted()
                    var ind = 1
                    for i in sortedKeys {
                        if val[i] != 0 {
                            ind += 1
                        }
                    }
                    self.ref.child("devicesAmount").setValue(ind - 1)
                }
            }
        })
    }
    
    func registerDevice() {
        self.ref.child("devices").child(LocalStorage.getString(key: LocalStorage.deviceName)).setValue(1)
    }
    
    func unregisterDevice() {
        self.ref.child("devices").child(LocalStorage.getString(key: LocalStorage.deviceName)).setValue(0)
    }
}

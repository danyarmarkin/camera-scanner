//
//  MainDeviceTableViewCell.swift
//  camera
//
//  Created by Данила Ярмаркин on 28.06.2021.
//

import UIKit
import Firebase

class MainDeviceTableViewCell: UITableViewCell {
    
    @IBOutlet weak var mainDeviceSwitch: UISwitch!
    
    var ref: DatabaseReference!
    let mainDeviceId = "mainDevice"
    let cameraConfId = "cameraConf"
    
    func configure() {
        ref = Database.database(url: "https://camera-scan-e5684-default-rtdb.europe-west1.firebasedatabase.app/").reference()
        if LocalStorage.getBool(key: LocalStorage.isMainDevice) {
            self.mainDeviceSwitch.isOn = true
        } else {
            self.mainDeviceSwitch.isOn = false
        }
        monitoringData()
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func onChanged(_ sender: UISwitch) {
        if sender.isOn {
            LocalStorage.set(key: LocalStorage.isMainDevice, val: true)
            ref.child(mainDeviceId).setValue(LocalStorage.getString(key:LocalStorage.deviceName))
        } else if LocalStorage.getBool(key: LocalStorage.isMainDevice) {
            self.mainDeviceSwitch.isOn = true
        }
    }
    
    func monitoringData()  {
        ref.child(mainDeviceId).observe(DataEventType.value, with: {(snapshot) in
            let value = snapshot.value
            if let val = value as? String {
                if val == LocalStorage.getString(key: LocalStorage.deviceName) {
                    LocalStorage.set(key: LocalStorage.isMainDevice, val: true)
                    self.mainDeviceSwitch.setOn(true, animated: true)
                } else {
                    LocalStorage.set(key: LocalStorage.isMainDevice, val: false)
                    self.mainDeviceSwitch.setOn(false, animated: true)
                }
            }
        })
    }
    
}

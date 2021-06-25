//
// Created by Данила Ярмаркин on 13.06.2021.
//

import Foundation
import UIKit
import Firebase

class SettingsViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var fpsTextField: UITextField!
    @IBOutlet weak var mainDeviceSwitch: UISwitch!
    @IBOutlet weak var deviceNameTextField: UITextField!
    @IBOutlet weak var iso: UITextField!
    @IBOutlet weak var fps: UITextField!
    @IBOutlet weak var shutter: UITextField!
    @IBOutlet weak var whiteBalance: UITextField!
    @IBOutlet weak var tint: UITextField!
    
    let localStorage = LocalStorage()

    var ref: DatabaseReference!
    let mainDeviceId = "mainDevice"
    let cameraConfId = "cameraConf"

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database(url: "https://camera-scan-e5684-default-rtdb.europe-west1.firebasedatabase.app/").reference()
        deviceNameTextField.delegate = self
        iso.delegate = self
        fps.delegate = self
        shutter.delegate = self
        whiteBalance.delegate = self
        tint.delegate = self
//        monitoringData()
        let name = LocalStorage.getString(key: LocalStorage.deviceName)
        if name != "" { deviceNameTextField.text = name }
        UIApplication.shared.isIdleTimerDisabled = true
        
        updateSettings()
    }
    
    func updateSettings() {
        iso.text = String(LocalStorage.getInt(key: LocalStorage.isoVal))
        if LocalStorage.getInt(key: LocalStorage.shutterVal) == 0 {
            LocalStorage.set(key: LocalStorage.shutterVal, val: 5)
        }
        shutter.text = String(1000 / LocalStorage.getInt(key: LocalStorage.shutterVal))
        whiteBalance.text = String(LocalStorage.getInt(key: LocalStorage.wbVal))
        fps.text = String(LocalStorage.getInt(key: LocalStorage.fpsVal))
    }

    @IBAction func setMainDevice(_ sender: UISwitch) {
        if sender.isOn {
            LocalStorage.set(key: LocalStorage.isMainDevice, val: true)
            ref.child(mainDeviceId).setValue(deviceNameTextField.text)
        } else if LocalStorage.getBool(key: LocalStorage.isMainDevice) {
            self.mainDeviceSwitch.isOn = true
        }
    }
    @IBAction func setDevice(_ sender: UITextField) {
        LocalStorage.set(key: LocalStorage.deviceName, val: sender.text ?? "aaa")
        print("changed")
    }

    @IBAction func inIsoChanged(_ sender: UITextField) {
        if let val = sender.text {
            let value = Int(val) ?? 32
            LocalStorage.set(key: LocalStorage.isoVal, val: value)
            ref.child("\(cameraConfId)/iso").setValue(value)
        }
    }
    
    @IBAction func onFPSChanged(_ sender: UITextField) {
        if let val = sender.text {
            let value = Int(val) ?? 24
            LocalStorage.set(key: LocalStorage.fpsVal, val: value)
            ref.child("\(cameraConfId)/fps").setValue(value)
        }
    }
    @IBAction func onShutterChanged(_ sender: UITextField) {
        if let val = sender.text {
            let value = round(Float(1000 / Int(val)!))
            LocalStorage.set(key: LocalStorage.shutterVal, val: value)
            ref.child("\(cameraConfId)/shutter").setValue(value)
        }
    }
    @IBAction func onWBChanged(_ sender: UITextField) {
        if let val = sender.text {
            let value = Int(val) ?? 5000
            LocalStorage.set(key: LocalStorage.wbVal, val: value)
            ref.child("\(cameraConfId)/wb").setValue(value)
        }
    }
    @IBAction func onTintChanged(_ sender: UITextField) {
        if let val = sender.text {
            let value = Int(val) ?? 0
            LocalStorage.set(key: LocalStorage.tintVal, val: value)
            ref.child("\(cameraConfId)/tint").setValue(value)
        }
    }
    
    func monitoringData() {
        ref.child(mainDeviceId).observe(DataEventType.value, with: {(snapshot) in
            let value = snapshot.value
            if let val = value as? String {
                if val == LocalStorage.getString(key: LocalStorage.deviceName) {
                    LocalStorage.set(key: LocalStorage.isMainDevice, val: true)
                    self.mainDeviceSwitch.isOn = true
                } else {
                    LocalStorage.set(key: LocalStorage.isMainDevice, val: false)
                    self.mainDeviceSwitch.isOn = false
                }
            }
        })
        
        ref.child("cameraConf/iso").observe(DataEventType.value, with: {(snapshot) in
            let value = snapshot.value
            if let val = value as? Int {
                LocalStorage.set(key: LocalStorage.isoVal, val: val)
                self.updateSettings()
            }
            
        })
        ref.child("cameraConf/shutter").observe(DataEventType.value, with: {(snapshot) in
            let value = snapshot.value
            if let val = value as? Int {
                LocalStorage.set(key: LocalStorage.shutterVal, val: val)
                self.updateSettings()
            }
            
        })
        ref.child("cameraConf/wb").observe(DataEventType.value, with: {(snapshot) in
            let value = snapshot.value
            if let val = value as? Int {
                LocalStorage.set(key: LocalStorage.wbVal, val: val)
                self.updateSettings()
            }
            
        })
        ref.child("cameraConf/tint").observe(DataEventType.value, with: {(snapshot) in
            let value = snapshot.value
            if let val = value as? Int {
                LocalStorage.set(key: LocalStorage.tintVal, val: val)
                self.updateSettings()
            }
            
        })
        ref.child("cameraConf/fps").observe(DataEventType.value, with: {(snapshot) in
            let value = snapshot.value
            if let val = value as? Int {
                LocalStorage.set(key: LocalStorage.fpsVal, val: val)
                self.updateSettings()
            }
            
        })
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

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
    let localStorage = LocalStorage()

    var ref: DatabaseReference!
    let mainDeviceId = "mainDevice"

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database(url: "https://camera-scan-e5684-default-rtdb.europe-west1.firebasedatabase.app/").reference()
        deviceNameTextField.delegate = self
        monitoringData()
        let name = LocalStorage.getString(key: LocalStorage.deviceName)
        if name != "" { deviceNameTextField.text = name }
    }

    @IBAction func setMainDevice(_ sender: UISwitch) {
        if sender.isOn {
            LocalStorage.set(key: LocalStorage.isMainDevice, val: true)
            ref.child(mainDeviceId).setValue(deviceNameTextField.text)
        } else if LocalStorage.getBool(key: LocalStorage.isMainDevice) {
            self.mainDeviceSwitch.isOn = true
        }
    }
    @IBAction func setDeviceName(_ sender: UITextField){
        LocalStorage.set(key: LocalStorage.deviceName, val: sender.text)
        print("changed")
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
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

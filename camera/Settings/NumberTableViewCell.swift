//
//  NumberTableViewCell.swift
//  camera
//
//  Created by Данила Ярмаркин on 25.06.2021.
//

import UIKit
import Firebase

class NumberTableViewCell: UITableViewCell, UITextFieldDelegate {
    var type: UITableViewCell.cellType!
    @IBOutlet weak var value: UITextField!
    @IBOutlet weak var name: UILabel!
    
    var ref: DatabaseReference!
    let mainDeviceId = "mainDevice"
    let cameraConfId = "cameraConf"
    
    func configure(type: UITableViewCell.cellType, val: Int) {
        ref = Database.database(url: "https://camera-scan-e5684-default-rtdb.europe-west1.firebasedatabase.app/").reference()
        self.type = type
        name.text = UITableViewCell.cellName[type]
        value.delegate = self
        value.text = String(val)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func onValueChanged(_ sender: UITextField) {
        switch type {
        case .iso:
            if let val = sender.text {
                let value = Int(val) ?? 32
                LocalStorage.set(key: LocalStorage.isoVal, val: value)
                ref.child("\(cameraConfId)/iso").setValue(value)
            }
            break
        case .shutter:
            if let val = sender.text {
                let value = round(Float(1000 / Int(val)!))
                LocalStorage.set(key: LocalStorage.shutterVal, val: value)
                ref.child("\(cameraConfId)/shutter").setValue(value)
            }
            break
        case .wb:
            if let val = sender.text {
                let value = Int(val) ?? 5000
                LocalStorage.set(key: LocalStorage.wbVal, val: value)
                ref.child("\(cameraConfId)/wb").setValue(value)
            }
            break
        case .tint:
            if let val = sender.text {
                let value = Int(val) ?? 0
                LocalStorage.set(key: LocalStorage.tintVal, val: value)
                ref.child("\(cameraConfId)/tint").setValue(value)
            }
            break
        case .fps:
            if let val = sender.text {
                let value = Int(val) ?? 24
                LocalStorage.set(key: LocalStorage.fpsVal, val: value)
                ref.child("\(cameraConfId)/fps").setValue(value)
            }
            break
        default:
            print("default")
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

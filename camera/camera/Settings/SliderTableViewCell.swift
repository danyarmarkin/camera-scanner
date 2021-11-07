//
//  SliderTableViewCell.swift
//  camera
//
//  Created by Данила Ярмаркин on 25.06.2021.
//

import UIKit
import Firebase

class SliderTableViewCell: UITableViewCell {
    
    var type: UITableViewCell.cellType!

    @IBOutlet weak var slider: UISlider!
    
    var ref: DatabaseReference!
    let mainDeviceId = "mainDevice"
    let cameraConfId = "cameraConf"
    
    
    func configure(type: UITableViewCell.cellType, max: Int = 100, min: Int = 0, val: Float) {
        ref = Database.database(url: "https://camera-scan-e5684-default-rtdb.europe-west1.firebasedatabase.app/").reference()
        slider.minimumValue = Float(min)
        slider.maximumValue = Float(max)
        slider.value = val
        self.type = type
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func onSliderChanged(_ sender: UISlider) {
        let val = round(sender.value)
        switch type {
        case .iso:
            print("set iso")
            LocalStorage.set(key: LocalStorage.isoVal, val: val)
            ref.child("\(cameraConfId)/iso").setValue(val)
            return
        case .shutter:
            print("set shutter")
            LocalStorage.set(key: LocalStorage.shutterVal, val: val)
            ref.child("\(cameraConfId)/shutter").setValue(val)
            return
        case .wb:
            print("set wb")
            LocalStorage.set(key: LocalStorage.wbVal, val: val)
            ref.child("\(cameraConfId)/wb").setValue(val)
            return
        case .tint:
            print("set tint")
            LocalStorage.set(key: LocalStorage.tintVal, val: val)
            ref.child("\(cameraConfId)/tint").setValue(val)
            return
        case .fps:
            print("set fps")
            LocalStorage.set(key: LocalStorage.fpsVal, val: val)
            ref.child("\(cameraConfId)/fps").setValue(val)
            return
        default:
            print("default")
        }
    }
    @IBAction func editingDidBegin(_ sender: UISlider) {
        LocalStorage.set(key: LocalStorage.sliderOn, val: true)
    }
    @IBAction func editingDidEnd(_ sender: UISlider) {
        LocalStorage.set(key: LocalStorage.sliderOn, val: false)
    }
    @IBAction func touchDown(_ sender: Any) {
        LocalStorage.set(key: LocalStorage.sliderOn, val: true)
    }
    
    @IBAction func touchUp(_ sender: Any) {
        LocalStorage.set(key: LocalStorage.sliderOn, val: false)
    }
}


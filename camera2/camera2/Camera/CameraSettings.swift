//
//  CameraSettings.swift
//  photo-camera
//
//  Created by Данила Ярмаркин on 17.09.2021.
//

import Foundation
import AVFoundation

class CameraSettings: NSObject{
    @objc dynamic var iso = 100
    @objc dynamic var shutter: NSObject!
    @objc dynamic var wb = 3000
    @objc dynamic var tint = 0
    @objc dynamic var focus: NSNumber!
    @objc dynamic var fps = 4
    @objc dynamic var colorSpace = 0
    
//    var ref: DatabaseReference!
    
    override init() {
        super.init()
        shutter = CMTimeMake(value: 1, timescale: 200) as NSObject
        fps = 4
        focus = 1.5
        tint = 0
        wb = 3000
        iso = 100
        colorSpace = 0
//        ref = Database.database(url: "https://camera-scan-e5684-default-rtdb.europe-west1.firebasedatabase.app/").reference()
    }
    
    func monitoringData() {
//        ref.child("cameraConf").child("iso").observe(.value) { snapshot in
//            if let val = snapshot.value as? Int {
//                self.iso = val
//            }
//        }
//        ref.child("cameraConf").child("shutter").observe(.value) { snapshot in
//            if let val = snapshot.value as? Int {
//                self.shutter = CMTimeMake(value: 1, timescale: Int32(val)) as NSObject
//            }
//        }
//        ref.child("cameraConf").child("wb").observe(.value) { snapshot in
//            if let val = snapshot.value as? Int {
//                self.wb = val
//            }
//        }
//        ref.child("cameraConf").child("tint").observe(.value) { snapshot in
//            if let val = snapshot.value as? Int {
//                self.tint = val
//            }
//        }
        let timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: {[self](timer) in
//            let iso = LocalStorage.getInt(key: LocalStorage.isoVal)
//            let shutter = CMTimeMake(value: 1, timescale: Int32(LocalStorage.getInt(key: LocalStorage.shutterVal)))
//            let wb = LocalStorage.getInt(key: LocalStorage.wbVal)
//            let tint = LocalStorage.getInt(key: LocalStorage.tintVal)
//            let fps = LocalStorage.getInt(key: LocalStorage.fpsVal)
//            let colorSpace = LocalStorage.getInt(key: LocalStorage.csVal)
//            if iso != self.iso {
//                self.iso = iso
//            }
//            if shutter != self.shutter as! CMTime {
//                self.shutter = shutter as NSObject
//            }
//            if wb != self.wb {
//                self.iso = wb
//            }
//            if tint != self.tint {
//                self.tint = tint
//            }
//            if fps != self.fps {
//                self.fps = fps
//            }
//            if colorSpace != self.colorSpace {
//                self.colorSpace = iso
//            }
//            self.iso += 10
        })
        timer.tolerance = 0.3
    }
}

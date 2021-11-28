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
    @objc dynamic var focusRange: AVCaptureDevice.AutoFocusRangeRestriction = .none
    
    let defaults = UserDefaults.standard
    
    
    override init() {
        super.init()
        shutter = CMTimeMake(value: 1, timescale: 200) as NSObject
        fps = 4
        focus = 1.5
        tint = 0
        wb = 3000
        iso = 100
        colorSpace = 0
    }
    
    func monitoringData() {
        let timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: {[self](timer) in
            let iso = CameraData.getData(.iso)
            let shutter = CMTimeMake(value: 1, timescale: Int32(CameraData.getData(.shutter)))
            let wb = CameraData.getData(.wb)
            let tint = CameraData.getData(.tint)
            let fps = CameraData.getData(.fps)
            let focusRange = FocusConfig.getFocusRangeRestriction()
            
            if iso != self.iso {
                self.iso = iso
            }
            if shutter != self.shutter as! CMTime {
                self.shutter = shutter as NSObject
            }
            if wb != self.wb {
                self.wb = wb
            }
            if tint != self.tint {
                self.tint = tint
            }
            if fps != self.fps {
                self.fps = fps
            }
            if focusRange != self.focusRange {
                self.focusRange = focusRange
            }
        })
        timer.tolerance = 0.3
    }
}

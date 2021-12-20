//
//  SettingsObserver.swift
//  camera2
//
//  Created by Данила Ярмаркин on 24.11.2021.
//

import Foundation
import UIKit
import CoreMedia

class SettingsObserver: NSObject {
    
    var observationIso: NSKeyValueObservation?
    var observationShutter: NSKeyValueObservation?
    var observationWB: NSKeyValueObservation?
    var observationTint: NSKeyValueObservation?
    var observationFocus: NSKeyValueObservation?
    var observationFps: NSKeyValueObservation?
    
    let cells: [UICollectionViewCell]!
    @objc let cameraSettings: CameraSettings!
    
    init(_ cells: [UICollectionViewCell], forSettings: CameraSettings) {
        cameraSettings = forSettings
        self.cells = cells
        super.init()
        
        observationIso = observe(\.cameraSettings.iso, options: [.new]) { object, change in
            self.cells[0].setVal(self.cameraSettings.iso)
        }
        
        observationShutter = observe(\.cameraSettings.shutter, options: [.new]) { object, change in
            self.cells[1].setVal(Int((self.cameraSettings.shutter as! CMTime).timescale))
        }
        
        observationWB = observe(\.cameraSettings.wb, options: [.new]) { object, change in
            self.cells[2].setVal(self.cameraSettings.wb)
        }
        
        observationTint = observe(\.cameraSettings?.tint, options: [.new]) { object, change in
            self.cells[3].setVal(self.cameraSettings.tint)
        }
        
        observationFps = observe(\.cameraSettings?.fps, options: [.new]) { object, change in
            self.cells[4].setVal(self.cameraSettings.fps)
        }
    }
}

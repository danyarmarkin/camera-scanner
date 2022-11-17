//
//  CameraSettingsObserver.swift
//  photo-camera
//
//  Created by Данила Ярмаркин on 18.09.2021.
//

import Foundation
import AVFoundation

class CameraSettingsObserver: NSObject {
    
    @objc var cameraSettings: CameraSettings!
    var observationIso: NSKeyValueObservation?
    var observationShutter: NSKeyValueObservation?
    var observationWB: NSKeyValueObservation?
    var observationTint: NSKeyValueObservation?
    var observationFps: NSKeyValueObservation?
    var observationFocus: NSKeyValueObservation?
    var observationFocusRange: NSKeyValueObservation?
    var observationStabilizationMode: NSKeyValueObservation?
    var captureDevice: AVCaptureDevice!
    var captureVideoOutput: AVCaptureMovieFileOutput!
    
    let defaults = UserDefaults.standard
    var focus = 0
    
    init(capDev: AVCaptureDevice, settings: CameraSettings) {
        cameraSettings = settings
        captureDevice = capDev
//        captureVideoOutput = output
        super.init()
        
        guard capDev.isExposureModeSupported(.custom) else {
            print("exposure mode unsupported")
            return
        }
        
        observationIso = observe(\.cameraSettings.iso, options: [.new]) { object, change in
            do {
                try self.captureDevice.lockForConfiguration()
                self.captureDevice.setExposureModeCustom(duration: self.cameraSettings.shutter as! CMTime, iso: Float(self.cameraSettings.iso), completionHandler: nil)
                self.captureDevice.unlockForConfiguration()
            } catch {return}
            
        }
        
        observationShutter = observe(\.cameraSettings.shutter, options: [.new]) { object, change in
            do {
                try self.captureDevice.lockForConfiguration()
                self.captureDevice.setExposureModeCustom(duration: self.cameraSettings.shutter as! CMTime, iso: Float(self.cameraSettings.iso), completionHandler: nil)
                self.captureDevice.unlockForConfiguration()
            } catch {return}
            
        }
        
        observationWB = observe(\.cameraSettings.wb, options: [.new]) { object, change in
            do {
                try self.captureDevice.lockForConfiguration()
                let wbGains = AVCaptureDevice.WhiteBalanceTemperatureAndTintValues(temperature: Float(self.cameraSettings.wb), tint: Float(self.cameraSettings.tint))
                self.captureDevice.setWhiteBalanceModeLocked(with: self.captureDevice.deviceWhiteBalanceGains(for: wbGains), completionHandler: nil)
                self.captureDevice.unlockForConfiguration()
            } catch {return}
            
        }
        observationTint = observe(\.cameraSettings?.tint, options: [.new]) { object, change in
            do {
                try self.captureDevice.lockForConfiguration()
                let wbGains = AVCaptureDevice.WhiteBalanceTemperatureAndTintValues(temperature: Float(self.cameraSettings.wb), tint: Float(self.cameraSettings.tint))
                self.captureDevice.setWhiteBalanceModeLocked(with: self.captureDevice.deviceWhiteBalanceGains(for: wbGains), completionHandler: nil)
                self.captureDevice.unlockForConfiguration()
            } catch {return}
        }
        observationFps = observe(\.cameraSettings?.fps, options: [.new]) { object, change in
            do {
                try self.captureDevice.lockForConfiguration()
                self.captureDevice.activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale: Int32(self.cameraSettings.fps))
                self.captureDevice.activeVideoMaxFrameDuration = CMTimeMake(value: 1, timescale: Int32(self.cameraSettings.fps))
                self.captureDevice.unlockForConfiguration()
            } catch {return}
        }
        observationFocusRange = observe(\.cameraSettings?.focusRange, options: [.new]) {object, change in
            do {
                try self.captureDevice.lockForConfiguration()
                self.captureDevice.autoFocusRangeRestriction = self.cameraSettings.focusRange
                self.captureDevice.unlockForConfiguration()
            } catch {return}
        }
        
//        observationStabilizationMode = observe(\.cameraSettings?.stabilizationMode, options: [.new]) {object, change in
//            do {
//                print("new stabilization Mode")
//                self.captureVideoOutput.connection(with: .video)?.preferredVideoStabilizationMode = self.cameraSettings.stabilizationMode
//            } catch {
//                return
//            }
//        }
    }
}

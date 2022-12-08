//
//  Storage.swift
//  camera2
//
//  Created by Данила Ярмаркин on 21.11.2021.
//

import Foundation
import AVFoundation

class CameraData {
    
    static let cameraDataKey = "com.kanistra.camera2.camera-data.camera-data"
    
    static let defaults = UserDefaults.standard
    
    enum type{
        case iso
        case shutter
        case wb
        case tint
        case fps
        case focus
        case stablization
        case codec
        case resolution
        case videoExtension
        case bitRate
    }
    
    static func getId(_ type: type) -> String {
        switch type {
        case .iso:
            return "com.kanistra.camera2.camera-data.iso"
        case .shutter:
            return "com.kanistra.camera2.camera-data.shutter"
        case .wb:
            return "com.kanistra.camera2.camera-data.wb"
        case .tint:
            return "com.kanistra.camera2.camera-data.tint"
        case .fps:
            return "com.kanistra.camera2.camera-data.fps"
        case .focus:
            return "com.kanistra.camera2.camera-data.focus"
        case .stablization:
            return "com.kanistra.camera2.camera-data.stabilization"
        case .codec:
            return "com.kanistra.camera2.camera-data.codec"
        case .resolution:
            return "com.kanistra.camera2.camera-data.resolution"
        case .videoExtension:
            return "com.kanistra.camera2.camera-data.video-extension"
        case .bitRate:
            return "com.kanistra.camera2.camera-data.bit-rate"
        }
    }
    
    static func setData(_ type: type, _ value: Int) {
        let id = getId(type)
        defaults.set(value, forKey: id)
    }
    
    static func getData(_ type: type) -> Int {
        let id = getId(type)
        return defaults.integer(forKey: id)
    }
    
    static func params(_ type: type, val: Int) -> String{
        switch type {
        case .iso, .shutter, .wb, .tint, .fps, .bitRate:
            return "\(val)"
        case .focus:
            switch val {
            case 1:
                return "near"
            case 2:
                return "far"
            default:
                return "none"
            }
        case .stablization:
            switch val {
            case 1:
                return "standart"
            case 2:
                return "auto"
            case 3:
                return "cinematic"
            case 4:
                return "cinematic+"
            default:
                return "none"
            }
        case .codec:
            switch val {
            case 1:
                return "H264"
            case 2:
                return "ProRes"
            default:
                return "HEVC"
            }
        case .resolution:
            switch val {
            case 1:
                return "Full HD"
            case 2:
                return "photo"
            default:
                return "4K"
            }
        case .videoExtension:
            switch val {
            case 1:
                return "MP4"
            default:
                return "MOV"
            }
        }
    }
}

class ConfigurationProfiles {
    
    static let defalts = UserDefaults.standard
    
    static let key = "com.kanistra.camera2.camera-data.configuration-profile"
    static let keys = ["ISO", "Shutter", "WB", "Tint", "FPS", "Focus", "Stabilization", "Codec", "Resolution", "Extension"]
    
    static func getProfiles() -> [[String: Any]] {
        let val = defalts.value(forKey: key)
        if let v = val as? [[String: Any]] {
            return v
        }
        return []
    }
    
    static func setProfiles(_ profiles: [[String:Any]]) {
        defalts.set(profiles, forKey: key)
    }
    
    static func addProfile(_ profile: [String: Any]) {
        var profiles = getProfiles()
        profiles.append(profile)
        defalts.set(profiles, forKey: key)
    }
    
    static func removeProfile(_ index: Int) {
        var profiles = getProfiles()
        profiles.remove(at: index)
        defalts.set(profiles, forKey: key)
    }
    
    static func typeFromKey(_ key: String) -> CameraData.type{
        switch key {
        case keys[0]:
            return .iso
        case keys[1]:
            return .shutter
        case keys[2]:
            return .wb
        case keys[3]:
            return .tint
        case keys[4]:
            return .fps
        case keys[5]:
            return .focus
        case keys[6]:
            return .stablization
        case keys[7]:
            return .codec
        case keys[8]:
            return .resolution
        case keys[9]:
            return .videoExtension
        default:
            return .iso
        }
    }
    
    static func setProfileData(_ profile: [String: Any]) {
        var index = 0
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { timer in
            if index < keys.count {
                CameraData.setData(typeFromKey(keys[index]), profile[keys[index]] as! Int)
                Server.setParam(typeFromKey(keys[index]), profile[keys[index]] as! Int)
                index += 1
            } else {
                timer.invalidate()
            }
        })
    }
}

class CameraTypeConfig {
    static let defalts = UserDefaults.standard
    static let key = "com.kanistra.camera2.camera-data.camera-type"
    static let cameraTypeKey = "com.kanistra.camera2.camera-data.camera-type.notification"
    
    static func setCameraType(_ type: AVCaptureDevice.DeviceType) {
        if #available(iOS 15.4, *) {
            switch type {
            case .builtInWideAngleCamera:
                defalts.set("wide", forKey: key)
                break
            case .builtInUltraWideCamera:
                defalts.set("ultra_wide", forKey: key)
                break
            case .builtInDualCamera:
                defalts.set("dual", forKey: key)
                break
            case .builtInDualWideCamera:
                defalts.set("dual_wide", forKey: key)
                break
            case .builtInLiDARDepthCamera:
                defalts.set("lidar", forKey: key)
                break
            case .builtInTelephotoCamera:
                defalts.set("telephoto", forKey: key)
                break
            default:
                defalts.set("wide", forKey: key)
            }
        } else {
            defalts.set("wide", forKey: key)
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(cameraTypeKey), object: nil)
    }
    
    static func getCameraType() -> AVCaptureDevice.DeviceType {
        let type = defalts.string(forKey: key)
        switch type {
        case "wide":
            return .builtInWideAngleCamera
        case "ultra_wide":
            return .builtInUltraWideCamera
        case "dual":
            return .builtInDualCamera
        case "dual_wide":
            return .builtInDualWideCamera
        case "lidar":
            if #available(iOS 15.4, *) {
                return .builtInLiDARDepthCamera
            } else {
                return .builtInWideAngleCamera
            }
        case "telephoto":
            return .builtInTelephotoCamera
            
        default:
            return .builtInWideAngleCamera
        }
    }
}

class FocusConfig {
    static let defalts = UserDefaults.standard
    static let key = "com.kanistra.camera2.camera-data.focus-range-restriction"
    
    static func setFocusRangeRestriction(_ type: AVCaptureDevice.AutoFocusRangeRestriction) {
        switch type {
        case .none:
            defalts.set("none", forKey: key)
        case .near:
            defalts.set("near", forKey: key)
        case .far:
            defalts.set("far", forKey: key)
        @unknown default:
            fatalError()
        }
    }
    
    static func getFocusRangeRestriction() -> AVCaptureDevice.AutoFocusRangeRestriction {
        let val = defalts.string(forKey: key)
        switch val {
        case "near":
            return .near
        case "far":
            return .far
        default:
            return .none
        }
    }
}

class StabilizationConfig {
    static let defalts = UserDefaults.standard
    static let key = "com.kanistra.camera2.camera-data.stabilization-mode"
    
    static func setStablilizationMode(_ mode: AVCaptureVideoStabilizationMode) {
        switch mode {
        case .off:
            defalts.set("off", forKey: key)
        case .standard:
            defalts.set("standart", forKey: key)
        case .cinematic:
            defalts.set("cinematic", forKey: key)
        case .cinematicExtended:
            defalts.set("cinematic-extended", forKey: key)
        case .auto:
            defalts.set("auto", forKey: key)
        @unknown default:
            fatalError()
        }
    }
    
    static func getStablizationMode() ->AVCaptureVideoStabilizationMode {
        let val = defalts.string(forKey: key)
        switch val {
        case "auto":
            return .auto
        case "standart":
            return .standard
        case "cinematic":
            return .cinematic
        case "cinematic-extended":
            return .cinematicExtended
        default:
            return .off
        }
    }
}

class NamingConf {
    static let defalts = UserDefaults.standard
    static let key = "com.kanistra.camera2.camera-data.naming-mask"
    
    static func setNaming(_ name: String) {
        defalts.set(name, forKey: key)
    }
    
    static func getNaming() -> String {
        defalts.string(forKey: key) ?? "nnnRRRR"
    }
}

class SessionConfig {
    static let isStartKey = "com.kanistra.camera2.session-data.isStart"
    static let sessionNameKey = "com.kanistra.camera2.session-data.session-name"
    static let sessionObjectKey = "com.kanistra.camera2.session-data.session-object"
    static let serialIndexKey = "com.kanistra.camera2.session-data.serial-index"
    
    static let isStartKeyC = "com.kanistra.camera2.session-data.isStart.c"
    static let sessionNameKeyC = "com.kanistra.camera2.session-data.session-name.c"
    static let sessionObjectKeyC = "com.kanistra.camera2.session-data.session-object.c"
    
    static let defaults = UserDefaults.standard
    
    static let storageSessionNameKey = "com.kanistra.camera2.session-data.session-name.storage"
    static let storageSessionObjectKey = "com.kanistra.camera2.session-data.session-object.storage"
    static let currentSessionIndexKey = "com.kanistra.camera2.session-data.session-current-index.storage"
    
    static func setData(_ type: SessionDataType, _ v: String) {
        switch type {
        case .isStart:
            NotificationCenter.default.post(name: NSNotification.Name(isStartKey), object: nil, userInfo: ["value": v])
        case .sessionObject:
            NotificationCenter.default.post(name: NSNotification.Name(sessionObjectKey), object: nil, userInfo: ["value": v])
            defaults.set(v, forKey: storageSessionObjectKey)
        case .sessionName:
            NotificationCenter.default.post(name: NSNotification.Name(sessionNameKey), object: nil, userInfo: ["value": v])
            defaults.set(v, forKey: storageSessionNameKey)
        }
    }
    
    static func setData(forCamera type: SessionDataType, _ v: String) {
        switch type {
        case .isStart:
            NotificationCenter.default.post(name: NSNotification.Name(isStartKeyC), object: nil, userInfo: ["value": v])
        case .sessionObject:
            NotificationCenter.default.post(name: NSNotification.Name(sessionObjectKeyC), object: nil, userInfo: ["value": v])
            defaults.set(v, forKey: storageSessionObjectKey)
        case .sessionName:
            NotificationCenter.default.post(name: NSNotification.Name(sessionNameKeyC), object: nil, userInfo: ["value": v])
            defaults.set(v, forKey: storageSessionNameKey)
        }
    }
    
    static func setCurrentIndex(_ index: Int, withNotify notify: Bool = true) {
        defaults.set(index, forKey: currentSessionIndexKey)
        if notify {
            NotificationCenter.default.post(name: NSNotification.Name(serialIndexKey), object: nil, userInfo: ["value": index])
        }
    }
    
    static func getSessionName() -> String {
        return defaults.string(forKey: storageSessionNameKey) ?? "000AAAA"
    }
    
    static func getSessionObject() -> String {
        return defaults.string(forKey: storageSessionObjectKey) ?? "object"
    }
    
    static func updateSession(updateIndex: Bool = true) {
        let index = defaults.integer(forKey: currentSessionIndexKey) + (updateIndex ? 1 : 0)
        var ind: Int = index
        let mask = NamingConf.getNaming()
        
        let alph = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let numb = "0123456789"
        
        var r = ""
        
        // N - random number
        // n - serial number
        // R - random letter
        
        for i in String(mask.reversed()) {
            switch i {
            case "N":
                r = String(numb.randomElement() ?? "0") + r
                ind = index
                
            case "n":
                r = String(ind % 10) + r
                ind /= 10
                
            case "R":
                r = String(alph.randomElement() ?? "A") + r
                ind = index
                
            default:
                break
            }
        }
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { _ in
                if updateIndex { setCurrentIndex(index) }
            }
            setData(.sessionName, r)
        }
    }
    
    enum SessionDataType {
        case isStart
        case sessionName
        case sessionObject
    }
}

class DevicesData {
    static let batteryKey = "com.kanistra.camera2.devices-data.battery"
    static let storageKey = "com.kanistra.camera2.devices-data.storage"
    static let totalStorageKey = "com.kanistra.camera2.devices-data.total-storage"
    static let isChargingKey = "com.kanistra.camera2.devices-data.charging"
    static let deviceDataKey = "com.kanistra.camera2.devices-data.device-data"
    
    static let deviceIndexStorageKey = "com.kanistra.camera2.devices-data.device-index.storage"
    static let devicesAmountStorageKey = "com.kanistra.camera2.devices-data.devices-amount.storage"
    static let deviceIndexKey = "com.kanistra.camera2.devices-data.device-index"
    static let devicesAmountKey = "com.kanistra.camera2.devices-data.devices-amount"
    
    static let devicesDataKey = "com.kanistra.camera2.devices-data.devices-data"
    
    static let defaults = UserDefaults.standard
    
    static func setData(_ data: [ConnectionDevice]) {
        NotificationCenter.default.post(name: NSNotification.Name(devicesDataKey), object: nil, userInfo: ["value": data])
    }
    
    static func setDeviceIndex(_ index: Int) {
        defaults.set(index, forKey: deviceIndexStorageKey)
        NotificationCenter.default.post(name: NSNotification.Name(deviceIndexKey), object: nil, userInfo: ["value": index])
    }
    
    static func setDevicesAmount(_ amount: Int) {
        defaults.set(amount, forKey: devicesAmountStorageKey)
        NotificationCenter.default.post(name: NSNotification.Name(devicesAmountKey), object: nil, userInfo: ["value": amount])
    }
    
    static func getDeviceIndex() -> Int {
        return defaults.integer(forKey: deviceIndexStorageKey)
    }
    
    static func getDevicesAmount() -> Int {
        return defaults.integer(forKey: devicesAmountStorageKey)
    }
}


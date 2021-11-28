//
//  Storage.swift
//  camera2
//
//  Created by Данила Ярмаркин on 21.11.2021.
//

import Foundation
import AVFoundation

class CameraData {
    
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
        case .iso, .shutter, .wb, .tint, .fps:
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
        for key in keys {
            CameraData.setData(typeFromKey(key), profile[key] as! Int)
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

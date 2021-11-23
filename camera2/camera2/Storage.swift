//
//  Storage.swift
//  camera2
//
//  Created by Данила Ярмаркин on 21.11.2021.
//

import Foundation

class CameraData {
    
    static let defaults = UserDefaults.standard
    
    enum type{
        case iso
        case shutter
        case wb
        case tint
        case fps
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
}

class ConfigurationProfiles {
    
    static let defalts = UserDefaults.standard
    
    static let key = "com.kanistra.camera2.camera-data.configuration-profile"
    
}

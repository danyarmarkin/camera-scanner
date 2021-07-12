//
// Created by Данила Ярмаркин on 16.06.2021.
//

import Foundation

class LocalStorage {
    static let defaults = UserDefaults.standard
    
    static let isoVal = "com.kanistra.camera.iso"  // iso
    static let fpsVal = "com.kanistra.camera.fps"  // fps
    static let shutterVal = "com.kanistra.camera.shutter"  // shutter
    static let wbVal = "com.kanistra.camera.wb"  // white balance
    static let tintVal = "com.kanistra.camera.tint"  // tint
    static let sliderOn = "com.kanistra.camera.slider-on"
    
    static let lampsOffVal = "com.kanistra.camera.lamps-off" // int (1 - 16)
    static let currentSession = "com.kanistra.camera.current-session" // string
    static let previousSession = "com.kanistra.camera.previous-session" // string
    static let sessionId = "com.kanistra.camera.session-id" // string (4 letters)
    static let sessionArray = "com.kanistra.camera.session-array" //array
    static let isMainDevice = "com.kanistra.camera.is-main-device" //bool
    static let deviceName = "com.kanistra.camera.device-name" //string (iPhone (Danila))
    static let devices = "com.kanistra.camera.devices" //array
    static let devicesAmount = "com.kanistra.camera.devices-amount" //int
    static let videoQuality = "com.kanistra.camera.video-quality"  // Float 0.0 - 1.0
    static let isVideoStarted = "com.kanistra.camera.is-video-started" // bool
    
    static let trashList = "com.kanistra.camera.trash-list" // dict
    
    static func set(key: String, val: Any) {
        defaults.set(val, forKey: key)
    }

    static func getInt(key: String) -> Int {
        let val = defaults.integer(forKey: key)
        return val
    }

    static func getFloat(key: String) -> Float {
        let val = defaults.float(forKey: key)
        return val
    }

    static func getString(key: String) -> String {
        guard let val = defaults.string(forKey: key) else { return "" }
        return val
    }

    static func getBool(key: String) -> Bool {
        let val = defaults.bool(forKey: key)
        return val
    }

    static func getArray(key: String) -> [Any] {
        let val = defaults.array(forKey: key) ?? []
        return val
    }

    static func appendArray(key: String, value: Any) {
        var val = getArray(key: key)
        val.append(value)
        set(key: key, val: val)
    }

    static func removeArrayElement(key: String, index: Int) {
        var val = getArray(key: key)
        val.remove(at: index)
        set(key: key, val: val)
    }
    
    static func removeArrayStringElement(key: String, value: String) {
        let val = getArray(key: key)
        var val1: [String] = []
        if val is [String] {
            let countTo = val.count - 1
            if countTo == -1 {
                return
            }
            for i in 0...countTo {
                if !(val[i] as! String == value) {
                    val1.append(val[i] as! String)
                }
            }
        }
        set(key: key, val: val1)
    }
    
    static func getDictionary(key: String) -> Dictionary<String, Any>{
        let dict = defaults.dictionary(forKey: key) ?? ["AAAA": true]
        return dict
    }
    
    static func setToDictionary(key: String, value: Any, dictKey: String) {
        var val = getDictionary(key: key)
        val[dictKey] = value
        defaults.setValue(val, forKey: key)
    }
    
    static func removeFromDictionary(key: String, dictKey: String) {
        var val = getDictionary(key: key)
        val.removeValue(forKey: dictKey)
        defaults.setValue(val, forKey: key)
    }
    
    static func randomSessionId(length: Int) -> String {
      let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
}

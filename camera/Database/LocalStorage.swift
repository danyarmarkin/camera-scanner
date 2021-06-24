//
// Created by Данила Ярмаркин on 16.06.2021.
//

import Foundation

class LocalStorage {
    static let defaults = UserDefaults.standard
    static let isoVal = "com.kanistra.camera.iso"
    static let fpsVal = "com.kanistra.camera.fps"
    static let lampsOffVal = "com.kanistra.camera.lamps-off"
    static let currentSession = "com.kanistra.camera.current-session"
    static let sessionArray = "com.kanistra.camera.session-array"
    static let isMainDevice = "com.kanistra.camera.is-main-device"
    static let deviceName = "com.kanistra.camera.device-name"

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
    
    static func randomSessionId(length: Int) -> String {
      let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
}

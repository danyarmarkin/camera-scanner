//
//  Session.swift
//  camera2
//
//  Created by Данила Ярмаркин on 07.11.2021.
//

import Foundation
import simd

class Session {
    var objectName = ""
    var sessionName = ""
    var deviceIndex = 0
    var deviceAmount = 0
    var date = ""
    var time = ""
    var sessionIndex = ""
    
    init() {
        
    }
    
    func getFullName() -> String {
        if date == "" {
            return "\(sessionIndex)\(objectName)_\(sessionName)_\(deviceIndex)\(deviceAmount)"
        }
        
        if time == "" {
            return "\(sessionIndex)\(objectName)_\(sessionName)_\(deviceIndex)\(deviceAmount)_\(date)"
        }
        return "\(sessionIndex)\(objectName)_\(sessionName)_\(deviceIndex)\(deviceAmount)_\(date)_\(time)"
    }
    
    func getShortName() -> String {
        "_\(sessionIndex)\(sessionName)_\(deviceIndex)\(deviceAmount)"
    }
    
    func getFileName() -> String {
        return getFullName() + ".mov"
    }
}

//
//  Server.swift
//  camera2
//
//  Created by Данила Ярмаркин on 08.12.2021.
//

import Foundation
import AVFoundation
import UIKit

class Server {
    static let isTest = true
    static var firebasePath: String {
        if isTest { return "http://192.168.31.115:9002?ns=camera-scan-e5684-default-rtdb" }
        return "https://camera-scan2.europe-west1.firebasedatabase.app/"
    }



    static func setParam(_ type: CameraData.type, _ value: Int) {
        NotificationCenter.default.post(name: NSNotification.Name(CameraData.cameraDataKey), object: nil, userInfo: ["key": CameraData.getId(type), "value": value])
    }
    
    static func updateParam() {
        NotificationCenter.default.post(name: NSNotification.Name(CameraData.cameraDataKey), object: nil, userInfo: ["key": CameraData.getId(.iso), "value": CameraData.getData(.iso)])
        NotificationCenter.default.post(name: NSNotification.Name(CameraData.cameraDataKey), object: nil, userInfo: ["key": CameraData.getId(.shutter), "value": CameraData.getData(.shutter)])
        NotificationCenter.default.post(name: NSNotification.Name(CameraData.cameraDataKey), object: nil, userInfo: ["key": CameraData.getId(.wb), "value": CameraData.getData(.wb)])
        NotificationCenter.default.post(name: NSNotification.Name(CameraData.cameraDataKey), object: nil, userInfo: ["key": CameraData.getId(.tint), "value": CameraData.getData(.tint)])
        NotificationCenter.default.post(name: NSNotification.Name(CameraData.cameraDataKey), object: nil, userInfo: ["key": CameraData.getId(.fps), "value": CameraData.getData(.fps)])
    }
    
    static func getDeviceName() -> String{
        return UIDevice.current.name + "-" + UIDevice.current.model
    }
    
    static var battery = {
        return Int(floor(UIDevice.current.batteryLevel * 100))
    }
    
    static var storage = {
        return Int(DiskStatus.freeDiskSpaceInBytes / 1024 / 1024 / 1024)
    }
    
    static var totalStorage = {
        return Int(DiskStatus.totalDiskSpaceInBytes / 1024 / 1024 / 1024)
    }
    
    func updateDeviceStatus() {
        UIDevice.current.isBatteryMonitoringEnabled = true
        var battery = 0
        var storage = 0
        var totalStorage = 0
        
        let timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) {timer in
            if battery != Int(floor(UIDevice.current.batteryLevel * 100)) {
                battery = Int(floor(UIDevice.current.batteryLevel * 100))
                NotificationCenter.default.post(name: Notification.Name(DevicesData.deviceDataKey), object: nil, userInfo: ["key": DevicesData.batteryKey, "value": battery])
            }
            if storage != Int(DiskStatus.freeDiskSpaceInBytes / 1024 / 1024 / 1024) {
                storage = Int(DiskStatus.freeDiskSpaceInBytes / 1024 / 1024 / 1024)
                NotificationCenter.default.post(name: Notification.Name(DevicesData.deviceDataKey), object: nil, userInfo: ["key": DevicesData.storageKey, "value": storage])
            }
            if totalStorage != Int(DiskStatus.totalDiskSpaceInBytes / 1024 / 1024 / 1024) {
                totalStorage = Int(DiskStatus.totalDiskSpaceInBytes / 1024 / 1024 / 1024)
                NotificationCenter.default.post(name: Notification.Name(DevicesData.deviceDataKey), object: nil, userInfo: ["key": DevicesData.totalStorageKey, "value": totalStorage])
            }
        }
        timer.tolerance = 1
    }
    
    static func sendDeviceLocation(accelData: [Float], compassData: Int) {
//        ref.child("accelData").child(getDeviceName()).child("x").setValue(accelData[0])
//        ref.child("accelData").child(getDeviceName()).child("y").setValue(accelData[1])
//        ref.child("accelData").child(getDeviceName()).child("z").setValue(accelData[2])
//        ref.child("compassData").child(getDeviceName()).setValue(compassData)
    }
}

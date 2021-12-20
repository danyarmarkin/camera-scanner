//
//  Server.swift
//  camera2
//
//  Created by Данила Ярмаркин on 08.12.2021.
//

import Foundation
import AVFoundation
import Firebase
import UIKit

class Server {
    static let firebasePath = "https://camera-scan2.europe-west1.firebasedatabase.app/"
    static let ref = Database.database(url: firebasePath).reference()
    
    static func setParam(_ type: CameraData.type, _ value: Int) {
        let reference = ref.child("cameraSettings")
        switch type{
        case .iso:
            reference.child("iso").setValue(value)
        case .shutter:
            reference.child("shutter").setValue(value)
        case .wb:
            reference.child("wb").setValue(value)
        case .tint:
            reference.child("tint").setValue(value)
        case .fps:
            reference.child("fps").setValue(value)
        case .focus:
            reference.child("focus").setValue(value)
        case .stablization:
            reference.child("stabilization").setValue(value)
        case .codec:
            reference.child("codec").setValue(value)
        case .resolution:
            reference.child("resolution").setValue(value)
        case .videoExtension:
            reference.child("extension").setValue(value)
        case .bitRate:
            reference.child("bitRate").setValue(value)
        }
    }
    
    static func setNaming(_ name: String) {
        ref.child("sessionLife").child("naming").setValue(name)
    }
    
    static func serialNull() {
        ref.child("sessionLife").child("serial").setValue(0)
    }
    
    static func getDeviceName() -> String{
        return UIDevice.current.name + "-" + UIDevice.current.model
    }
    
    static func registerDevice() {
        ref.child("devices").child(getDeviceName()).setValue(1)
    }
    
    static func unregisterDevice() {
        ref.child("devices").child(getDeviceName()).setValue(0)
    }
    
    func monitoringData() {
        let reference = Server.ref.child("cameraSettings")
        reference.child("iso").observe(.value) { snapshot in
            let val = snapshot.value
            if let value = val as? Int {
                CameraData.setData(.iso, value)
            }
        }
        reference.child("shutter").observe(.value) { snapshot in
            let val = snapshot.value
            if let value = val as? Int {
                CameraData.setData(.shutter, value)
            }
        }
        reference.child("wb").observe(.value) { snapshot in
            let val = snapshot.value
            if let value = val as? Int {
                CameraData.setData(.wb, value)
            }
        }
        reference.child("tint").observe(.value) { snapshot in
            let val = snapshot.value
            if let value = val as? Int {
                CameraData.setData(.tint, value)
            }
        }
        reference.child("fps").observe(.value) { snapshot in
            let val = snapshot.value
            if let value = val as? Int {
                CameraData.setData(.fps, value)
            }
        }
        Server.ref.child("sessionLife").child("naming").observe(.value) {snapshot in
            let val = snapshot.value
            if let value = val as? String {
                NamingConf.setNaming(value)
            }
        }
    }
}

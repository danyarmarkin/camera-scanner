//
//  BluetoothPeripheral.swift
//  camera2
//
//  Created by Данила Ярмаркин on 04.10.2022.
//

import Foundation
import CoreBluetooth
import UIKit

class BluetoothPeripheral: NSObject {
    
    var peripheralManager: CBPeripheralManager!
    
    var isoCharacteristic: CBMutableCharacteristic!
    var shutterCharacteristic: CBMutableCharacteristic!
    var wbCharacteristic: CBMutableCharacteristic!
    var tintCharacteristic: CBMutableCharacteristic!
    var fpsCharacteristic: CBMutableCharacteristic!
    
    var sessionNameCharacteristic: CBMutableCharacteristic!
    var sessionObjectCharacteristic: CBMutableCharacteristic!
    var isStartCharacteristic: CBMutableCharacteristic!
    var nameMaskCharacteristic: CBMutableCharacteristic!
    var serialIndexCharacteristic: CBMutableCharacteristic!
    
    var storageCharacteristic: CBMutableCharacteristic!
    var totalStorageCharacteristic: CBMutableCharacteristic!
    var batteryCharacteristic: CBMutableCharacteristic!
    var isChargingCharacteristic: CBMutableCharacteristic!
    
    var devicesCharacteristic: CBMutableCharacteristic!
    
    var delegate: ViewController!
    
    func configure() {
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(cameraDataDidUpdate(_:)), name: NSNotification.Name(CameraData.cameraDataKey), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(deviceDataDidUpdate(_:)), name: NSNotification.Name(DevicesData.deviceDataKey), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onStartSession(_:)), name: Notification.Name(SessionConfig.isStartKey), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onSessionName(_:)), name: Notification.Name(SessionConfig.sessionNameKey), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onSessionObject(_:)), name: Notification.Name(SessionConfig.sessionObjectKey), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onSerialIndex(_:)), name: NSNotification.Name(SessionConfig.serialIndexKey), object: nil)
    }
    
    @objc func onStartSession(_ notification: Notification) {
        let info = notification.userInfo as? [String: Any] ?? [:]
        peripheralManager.updateValue((info["value"] as! String).data(using: .unicode)!, for: isStartCharacteristic, onSubscribedCentrals: nil)
    }
    
    @objc func onSessionName(_ notification: Notification) {
        let info = notification.userInfo as? [String: Any] ?? [:]
        peripheralManager.updateValue((info["value"] as! String).data(using: .unicode)!, for: sessionNameCharacteristic, onSubscribedCentrals: nil)
    }
    
    @objc func onSessionObject(_ notification: Notification) {
        let info = notification.userInfo as? [String: Any] ?? [:]
        peripheralManager.updateValue((info["value"] as! String).data(using: .unicode)!, for: sessionObjectCharacteristic, onSubscribedCentrals: nil)
    }
    
    @objc func onSerialIndex(_ notification: Notification) {
        let info = notification.userInfo as? [String: Any] ?? [:]
        peripheralManager.updateValue(String(info["value"] as! Int).data(using: .unicode)!, for: serialIndexCharacteristic, onSubscribedCentrals: nil)
    }
    
    @objc func cameraDataDidUpdate(_ notification: Notification) {
        let info = notification.userInfo as? [String: Any] ?? [:]
        switch info["key"] as! String {
        case CameraData.getId(.iso):
            peripheralManager.updateValue(String((info["value"] as! Int)).data(using: .unicode)!, for: isoCharacteristic, onSubscribedCentrals: nil)
        case CameraData.getId(.shutter):
            peripheralManager.updateValue(String((info["value"] as! Int)).data(using: .unicode)!, for: shutterCharacteristic, onSubscribedCentrals: nil)
        case CameraData.getId(.wb):
            peripheralManager.updateValue(String((info["value"] as! Int)).data(using: .unicode)!, for: wbCharacteristic, onSubscribedCentrals: nil)
        case CameraData.getId(.tint):
            peripheralManager.updateValue(String((info["value"] as! Int)).data(using: .unicode)!, for: tintCharacteristic, onSubscribedCentrals: nil)
        case CameraData.getId(.fps):
            peripheralManager.updateValue(String((info["value"] as! Int)).data(using: .unicode)!, for: fpsCharacteristic, onSubscribedCentrals: nil)
        default:
            break
        }
    }
    
    @objc func deviceDataDidUpdate(_ notification: Notification) {
        let info = notification.userInfo as? [String: Any] ?? [:]
        switch info["key"] as! String {
        case DevicesData.batteryKey:
            guard batteryCharacteristic != nil else { return }
            peripheralManager.updateValue(String((info["value"] as! Int)).data(using: .unicode)!, for: batteryCharacteristic, onSubscribedCentrals: nil)
        case DevicesData.storageKey:
            guard storageCharacteristic != nil else { return }
            peripheralManager.updateValue(String((info["value"] as! Int)).data(using: .unicode)!, for: storageCharacteristic, onSubscribedCentrals: nil)
        case DevicesData.totalStorageKey:
            guard totalStorageCharacteristic != nil else { return }
            peripheralManager.updateValue(String((info["value"] as! Int)).data(using: .unicode)!, for: totalStorageCharacteristic, onSubscribedCentrals: nil)
        default:
            break
        }
    }
    
    var connectionDevices: [ConnectionDevice] = []
    var devicesCharacteristicIndex = 0
    
}

extension BluetoothPeripheral: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .poweredOn:
            // ... so start working with the peripheral
            print("CBManager is powered on")
            
            isoCharacteristic = CBMutableCharacteristic(type: BluetoothConstants.iso, properties: [.notify, .read, .writeWithoutResponse], value: nil, permissions: [.readable, .writeable])
            shutterCharacteristic = CBMutableCharacteristic(type: BluetoothConstants.shutter, properties: [.notify, .read, .writeWithoutResponse], value: nil, permissions: [.readable, .writeable])
            wbCharacteristic = CBMutableCharacteristic(type: BluetoothConstants.wb, properties: [.notify, .read, .writeWithoutResponse], value: nil, permissions: [.readable, .writeable])
            tintCharacteristic = CBMutableCharacteristic(type: BluetoothConstants.tint, properties: [.notify, .read, .writeWithoutResponse], value: nil, permissions: [.readable, .writeable])
            fpsCharacteristic = CBMutableCharacteristic(type: BluetoothConstants.fps, properties: [.notify, .read, .writeWithoutResponse], value: nil, permissions: [.readable, .writeable])
            sessionNameCharacteristic = CBMutableCharacteristic(type: BluetoothConstants.sessionName, properties: [.notify, .read, .writeWithoutResponse], value: nil, permissions: [.readable, .writeable])
            sessionObjectCharacteristic = CBMutableCharacteristic(type: BluetoothConstants.sessionObject, properties: [.notify, .read, .writeWithoutResponse], value: nil, permissions: [.readable, .writeable])
            isStartCharacteristic = CBMutableCharacteristic(type: BluetoothConstants.isStart, properties: [.notify, .read, .writeWithoutResponse], value: nil, permissions: [.readable, .writeable])
            nameMaskCharacteristic = CBMutableCharacteristic(type: BluetoothConstants.nameMask, properties: [.notify, .read, .writeWithoutResponse], value: nil, permissions: [.readable, .writeable])
            serialIndexCharacteristic = CBMutableCharacteristic(type: BluetoothConstants.serialIndex, properties: [.notify, .read, .writeWithoutResponse], value: nil, permissions: [.readable, .writeable])
            batteryCharacteristic = CBMutableCharacteristic(type: BluetoothConstants.battery, properties: [.notify, .read, .writeWithoutResponse], value: nil, permissions: [.readable, .writeable])
            storageCharacteristic = CBMutableCharacteristic(type: BluetoothConstants.storage, properties: [.notify, .read, .writeWithoutResponse], value: nil, permissions: [.readable, .writeable])
            totalStorageCharacteristic = CBMutableCharacteristic(type: BluetoothConstants.totalStorage, properties: [.notify, .read, .writeWithoutResponse], value: nil, permissions: [.readable, .writeable])
            isChargingCharacteristic = CBMutableCharacteristic(type: BluetoothConstants.isCharging, properties: [.notify, .read, .writeWithoutResponse], value: nil, permissions: [.readable, .writeable])
            devicesCharacteristic = CBMutableCharacteristic(type: BluetoothConstants.devices, properties: [.notify, .read, .writeWithoutResponse], value: nil, permissions: [.readable, .writeable])
        
            
            let transferService = CBMutableService(type: BluetoothConstants.service, primary: true)
            transferService.characteristics = [isoCharacteristic, shutterCharacteristic, wbCharacteristic, tintCharacteristic, fpsCharacteristic, sessionNameCharacteristic, sessionObjectCharacteristic, isStartCharacteristic, nameMaskCharacteristic, batteryCharacteristic, storageCharacteristic, totalStorageCharacteristic, isChargingCharacteristic, devicesCharacteristic, serialIndexCharacteristic]

            peripheralManager.add(transferService)
            
            peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [BluetoothConstants.service]])
            
        case .poweredOff:
            print("CBManager is not powered on")
            return
        case .resetting:
            print("CBManager is resetting")
            return
        case .unauthorized:
            print("unathorized")
        case .unknown:
            print("CBManager state is unknown")
            return
        case .unsupported:
            print("Bluetooth is not supported on this device")
            return
        @unknown default:
            print("A previously unknown peripheral manager state occurred")
            return
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        print("write")
        for request in requests {
            let v = String(data: request.value!, encoding: .unicode)
            
            switch request.characteristic.uuid {
            case BluetoothConstants.iso:
                CameraData.setData(.iso, (v! as NSString).integerValue)
                
            case BluetoothConstants.shutter:
                CameraData.setData(.shutter, (v! as NSString).integerValue)
                
            case BluetoothConstants.wb:
                CameraData.setData(.wb, (v! as NSString).integerValue)
                
            case BluetoothConstants.tint:
                CameraData.setData(.tint, (v! as NSString).integerValue)
                
            case BluetoothConstants.fps:
                CameraData.setData(.fps, (v! as NSString).integerValue)
                
            case BluetoothConstants.sessionName:
                SessionConfig.setData(forCamera: .sessionName, v ?? "000AAAA")
                
            case BluetoothConstants.sessionObject:
                SessionConfig.setData(forCamera: .sessionObject, v ?? "object")
                
            case BluetoothConstants.isStart:
                SessionConfig.setData(forCamera: .isStart, v ?? "0")
                
            case BluetoothConstants.nameMask:
                NamingConf.setNaming(v ?? "O_nnnRRRR_km")
                
            case BluetoothConstants.serialIndex:
                SessionConfig.setCurrentIndex((v! as NSString).integerValue, withNotify: false)
                
            case BluetoothConstants.devices:
                connectionDevices = []
                var components = (v! as NSString).components(separatedBy: "<n>")
                DevicesData.setDeviceIndex((components[components.count - 2] as NSString).integerValue)
                DevicesData.setDevicesAmount((components[components.count - 1] as NSString).integerValue)
                components.remove(at: components.count - 1)
                components.remove(at: components.count - 1)
                
                for d in components {
                    let f = d.components(separatedBy: "<f>")
                    if f.count < 5 { continue }
                    for i in 0...4 {
                        switch i {
                        case 0:
                            let cd = ConnectionDevice()
                            cd.name = f[i]
                            cd.isCentral = connectionDevices.count == 0
                            connectionDevices.append(cd)
                        case 1:
                            connectionDevices[connectionDevices.count - 1].battery = (f[i] as NSString).integerValue
                        case 2:
                            connectionDevices[connectionDevices.count - 1].storage = (f[i] as NSString).integerValue
                        case 3:
                            connectionDevices[connectionDevices.count - 1].totalStorage = (f[i] as NSString).integerValue
                        case 4:
                            connectionDevices[connectionDevices.count - 1].isCharging = (f[i] as NSString).integerValue == 1
                        default:
                            break
                        }
                    }
                }
                
                DevicesData.setData(connectionDevices)
                
            default:
                break
            }
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        switch characteristic.uuid {
        case BluetoothConstants.storage:
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                let storage = Server.storage()
                NotificationCenter.default.post(name: Notification.Name(DevicesData.deviceDataKey), object: nil, userInfo: ["key": DevicesData.storageKey, "value": storage])
            }
        case BluetoothConstants.totalStorage:
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                let totalStorage = Server.totalStorage()
                NotificationCenter.default.post(name: Notification.Name(DevicesData.deviceDataKey), object: nil, userInfo: ["key": DevicesData.totalStorageKey, "value": totalStorage])
            }
        case BluetoothConstants.battery:
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                let battery = Server.battery()
                NotificationCenter.default.post(name: Notification.Name(DevicesData.deviceDataKey), object: nil, userInfo: ["key": DevicesData.batteryKey, "value": battery])
            }
        default:
            break
        }
    }
}

//
//  BluetoothCentral.swift
//  camera2
//
//  Created by Данила Ярмаркин on 04.10.2022.
//

import Foundation
import CoreBluetooth
import UIKit

class BluetoothCentral: NSObject {
    
    var centralManager: CBCentralManager!
    var peripheralDevides: [PeripheralDevice]! = []
    
    var onDevicesChanged: (() -> Void)?
    var onDeviceDataChanged: ((_ name: String, _ key: String, _ value: Int) -> Void)?
    
    func configure() {
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(cameraDataDidUpdate(_:)), name: NSNotification.Name(CameraData.cameraDataKey), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(deviceDataDidUpdate(_:)), name: NSNotification.Name(DevicesData.deviceDataKey), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onStartSession(_:)), name: Notification.Name(SessionConfig.isStartKey), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onSessionName(_:)), name: Notification.Name(SessionConfig.sessionNameKey), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onSessionObject(_:)), name: Notification.Name(SessionConfig.sessionObjectKey), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onSerialIndex(_:)), name: NSNotification.Name(SessionConfig.serialIndexKey), object: nil)
    }
    
    @objc func onStartSession(_ notification: Notification) {
        let info = notification.userInfo as? [String: Any] ?? [:]
        for pd in peripheralDevides {
            pd.peripheral?.writeValue((info["value"] as! String).data(using: .unicode)!, for: pd.isStartCharacteristic!, type: .withoutResponse)
        }
    }
    
    @objc func onSessionName(_ notification: Notification) {
        let info = notification.userInfo as? [String: Any] ?? [:]
        for pd in peripheralDevides {
            pd.peripheral?.writeValue((info["value"] as! String).data(using: .unicode)!, for: pd.sessionNameCharacteristic!, type: .withoutResponse)
        }
    }
    
    @objc func onSessionObject(_ notification: Notification) {
        let info = notification.userInfo as? [String: Any] ?? [:]
        for pd in peripheralDevides {
            pd.peripheral?.writeValue((info["value"] as! String).data(using: .unicode)!, for: pd.sessionObjectCharacteristic!, type: .withoutResponse)
        }
    }
    
    @objc func onSerialIndex(_ notification: Notification) {
        let info = notification.userInfo as? [String: Any] ?? [:]
        for pd in peripheralDevides {
            pd.peripheral?.writeValue(String(info["value"] as! Int).data(using: .unicode)!, for: pd.serialIndexCharacteristic!, type: .withoutResponse)
        }
    }
    
    
    @objc func cameraDataDidUpdate(_ notification: Notification) {
        let info = notification.userInfo as? [String: Any] ?? [:]
        
        switch info["key"] as! String {
        case CameraData.getId(.iso):
            for pd in peripheralDevides {
                pd.peripheral?.writeValue(String((info["value"] as! Int)).data(using: .unicode)!, for: pd.isoCharacteristic!, type: .withoutResponse)
            }
        case CameraData.getId(.shutter):
            for pd in peripheralDevides {
                pd.peripheral?.writeValue(String((info["value"] as! Int)).data(using: .unicode)!, for: pd.shutterCharacteristic!, type: .withoutResponse)
            }
        case CameraData.getId(.wb):
            for pd in peripheralDevides {
                pd.peripheral?.writeValue(String((info["value"] as! Int)).data(using: .unicode)!, for: pd.wbCharacteristic!, type: .withoutResponse)
            }
        case CameraData.getId(.tint):
            for pd in peripheralDevides {
                pd.peripheral?.writeValue(String((info["value"] as! Int)).data(using: .unicode)!, for: pd.tintCharacteristic!, type: .withoutResponse)
            }
        case CameraData.getId(.fps):
            for pd in peripheralDevides {
                pd.peripheral?.writeValue(String((info["value"] as! Int)).data(using: .unicode)!, for: pd.fpsCharacteristic!, type: .withoutResponse)
            }
        default:
            break
        }
    }
    
    @objc func deviceDataDidUpdate(_ notification: Notification) {
        let info = notification.userInfo as? [String: Any] ?? [:]
        switch info["key"] as! String {
        case DevicesData.batteryKey:
            (onDeviceDataChanged ?? {_, _, _ in return})(UIDevice.current.name , DevicesData.batteryKey, info["value"] as! Int)
        case DevicesData.storageKey:
            (onDeviceDataChanged ?? {_, _, _ in return})(UIDevice.current.name , DevicesData.storageKey, info["value"] as! Int)
        case DevicesData.totalStorageKey:
            (onDeviceDataChanged ?? {_, _, _ in return})(UIDevice.current.name , DevicesData.totalStorageKey, info["value"] as! Int)
        default:
            break
        }
    }
    
    func peripherals() -> [CBPeripheral] {
        var p: [CBPeripheral] = []
        for pd in peripheralDevides {
            if pd.peripheral != nil {p.append(pd.peripheral!)}
        }
        return p
    }
    
    func getPeripheralDevice(_ peripheral: CBPeripheral) -> PeripheralDevice {
        for pd in peripheralDevides {
            if pd.peripheral == peripheral { return pd }
        }
        
        return PeripheralDevice()
    }
    
    func updateDevicesState(for devices: [ConnectionDevice]) {
        var s = ""
        for device in devices {
            for i in 0...4 {
                switch i {
                case 0:
                    s += String(device.name)
                case 1:
                    s += String(device.battery)
                case 2:
                    s += String(device.storage)
                case 3:
                    s += String(device.totalStorage)
                case 4:
                    s += String(device.isCharging)
                default:
                    break
                }
                s += "<f>"
            }
            s += "<n>"
        }
        
        var index = 2
        for pd in self.peripheralDevides {
            guard pd.devicesCharacteristic != nil else {continue}
            pd.peripheral?.writeValue((s + "\(index)<n>\(devices.count)").data(using: .unicode)!, for: pd.devicesCharacteristic!, type: .withoutResponse)
            index += 1
        }
        
        DevicesData.setDeviceIndex(1)
        DevicesData.setDevicesAmount(devices.count)
    }
}

extension BluetoothCentral: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("central.state is unknown")
        case .resetting:
            print("central.state is resetting")
        case .unsupported:
            print("central.state is unsupported")
        case .unauthorized:
            print("central.state is unauthorized")
        case .poweredOff:
            print("central.state is poweredOff")
        case .poweredOn:
            print("central.state is poweredOn")
            centralManager.scanForPeripherals(withServices: [BluetoothConstants.service], options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
        @unknown default:
            break
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if self.peripherals().contains(peripheral) {
            return
        }
        
        let pd = PeripheralDevice()
        pd.peripheral = peripheral
        self.peripheralDevides.append(pd)
        peripheral.delegate = self
        
        self.centralManager.connect(peripheral)
    }
    
    // MARK: ON CONNECT
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if self.peripherals().contains(peripheral) {
            print("peripheral connected!")
            peripheral.discoverServices([BluetoothConstants.service])
            
        }
    }
    
    // MARK: ON DISCONNECT
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("disconected: \(String(describing: peripheral.name))")
        
        for i in 0...peripheralDevides.count - 1 {
            if peripheralDevides[i].peripheral == peripheral {
                peripheralDevides.remove(at: i)
                break
            }
        }
        (onDevicesChanged ?? {})()
    }
}

// MARK: Peripheral delegate
extension BluetoothCentral: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                print((service.peripheral?.name ?? "undefined") as String)
                if service.uuid == BluetoothConstants.service {
                    print("device found")
                    (onDevicesChanged ?? {})()
                    peripheral.discoverCharacteristics(BluetoothConstants.characteristics, for: service)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                let pd = getPeripheralDevice(peripheral)
                
                switch characteristic.uuid {
                case BluetoothConstants.iso:
                    pd.isoCharacteristic = characteristic
                case BluetoothConstants.shutter:
                    pd.shutterCharacteristic = characteristic
                case BluetoothConstants.wb:
                    pd.wbCharacteristic = characteristic
                case BluetoothConstants.tint:
                    pd.tintCharacteristic = characteristic
                case BluetoothConstants.fps:
                    pd.fpsCharacteristic = characteristic
                case BluetoothConstants.sessionName:
                    pd.sessionNameCharacteristic = characteristic
                case BluetoothConstants.sessionObject:
                    pd.sessionObjectCharacteristic = characteristic
                case BluetoothConstants.isStart:
                    pd.isStartCharacteristic = characteristic
                case BluetoothConstants.nameMask:
                    pd.nameMaskCharacteristic = characteristic
                case BluetoothConstants.serialIndex:
                    pd.serialIndexCharacteristic = characteristic
                case BluetoothConstants.battery:
                    pd.batteryCharacteristic = characteristic
                case BluetoothConstants.storage:
                    pd.storageCharacteristic = characteristic
                case BluetoothConstants.totalStorage:
                    pd.totalStorageCharacteristic = characteristic
                case BluetoothConstants.isCharging:
                    pd.isChargingCharacteristic = characteristic
                case BluetoothConstants.devices:
                    pd.devicesCharacteristic = characteristic
                default:
                    break
                }
                
                pd.peripheral?.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            print(error as Any)
            return
        }
        
        let v = String(data: characteristic.value!, encoding: .unicode)
        
        switch characteristic.uuid {
        case BluetoothConstants.battery:
            (onDeviceDataChanged ?? {_, _, _ in return})(peripheral.name ?? "unnamed", DevicesData.batteryKey, (v! as NSString).integerValue)
            
        case BluetoothConstants.storage:
            print("central: storage")
            (onDeviceDataChanged ?? {_, _, _ in return})(peripheral.name ?? "unnamed", DevicesData.storageKey, (v! as NSString).integerValue)
            
        case BluetoothConstants.totalStorage:
            (onDeviceDataChanged ?? {_, _, _ in return})(peripheral.name ?? "unnamed", DevicesData.totalStorageKey, (v! as NSString).integerValue)
            
        default:
            break
            
        }
        
        for pd in peripheralDevides {
            switch characteristic.uuid {
            case BluetoothConstants.iso:
                CameraData.setData(.iso, (v! as NSString).integerValue)
                if pd.peripheral == peripheral || pd.isoCharacteristic == nil { continue }
                pd.peripheral?.writeValue(characteristic.value!, for: pd.isoCharacteristic!, type: .withoutResponse)
                
            case BluetoothConstants.shutter:
                CameraData.setData(.shutter, (v! as NSString).integerValue)
                if pd.peripheral == peripheral || pd.shutterCharacteristic == nil { continue }
                pd.peripheral?.writeValue(characteristic.value!, for: pd.shutterCharacteristic!, type: .withoutResponse)
                
            case BluetoothConstants.wb:
                CameraData.setData(.wb, (v! as NSString).integerValue)
                if pd.peripheral == peripheral || pd.wbCharacteristic == nil { continue }
                pd.peripheral?.writeValue(characteristic.value!, for: pd.wbCharacteristic!, type: .withoutResponse)
                
            case BluetoothConstants.tint:
                CameraData.setData(.tint, (v! as NSString).integerValue)
                if pd.peripheral == peripheral || pd.tintCharacteristic == nil { continue }
                pd.peripheral?.writeValue(characteristic.value!, for: pd.tintCharacteristic!, type: .withoutResponse)
                
            case BluetoothConstants.fps:
                CameraData.setData(.fps, (v! as NSString).integerValue)
                if pd.peripheral == peripheral || pd.fpsCharacteristic == nil { continue }
                pd.peripheral?.writeValue(characteristic.value!, for: pd.fpsCharacteristic!, type: .withoutResponse)
                
            case BluetoothConstants.sessionName:
                SessionConfig.setData(forCamera: .sessionName, v ?? "000AAAA")
                if pd.peripheral == peripheral || pd.sessionNameCharacteristic == nil { continue }
                pd.peripheral?.writeValue(characteristic.value!, for: pd.sessionNameCharacteristic!, type: .withoutResponse)
                
            case BluetoothConstants.sessionObject:
                SessionConfig.setData(forCamera: .sessionObject, v ?? "object")
                if pd.peripheral == peripheral || pd.sessionObjectCharacteristic == nil { continue }
                pd.peripheral?.writeValue(characteristic.value!, for: pd.sessionObjectCharacteristic!, type: .withoutResponse)
                
            case BluetoothConstants.isStart:
                SessionConfig.setData(forCamera: .isStart, v ?? "0")
                if pd.peripheral == peripheral || pd.isStartCharacteristic == nil { continue }
                pd.peripheral?.writeValue(characteristic.value!, for: pd.isStartCharacteristic!, type: .withoutResponse)
                
            case BluetoothConstants.nameMask:
                NamingConf.setNaming(v ?? "nnnRRRR")
                if pd.peripheral == peripheral || pd.nameMaskCharacteristic == nil { continue }
                pd.peripheral?.writeValue(characteristic.value!, for: pd.nameMaskCharacteristic!, type: .withoutResponse)
                
            case BluetoothConstants.serialIndex:
                SessionConfig.setCurrentIndex((v! as NSString).integerValue, withNotify: false)
                if pd.peripheral == peripheral || pd.serialIndexCharacteristic == nil { continue }
                pd.peripheral?.writeValue(characteristic.value!, for: pd.serialIndexCharacteristic!, type: .withoutResponse)
                
            default:
                break
            }
        }
    }
}

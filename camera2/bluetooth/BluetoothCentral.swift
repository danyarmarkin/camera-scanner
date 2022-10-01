//
//  BluetoothCentral.swift
//  bluetooth
//
//  Created by Данила Ярмаркин on 29.09.2022.
//

import Foundation
import CoreBluetooth


class BluetoothCentral: NSObject {
    
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral!
    var delegate: ViewController!
    var characteristic: CBCharacteristic!
    var characteristic2: CBCharacteristic!
    
    func configure(delegate: ViewController) {
        self.delegate = delegate
        centralManager = CBCentralManager(delegate: self, queue: nil)
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
            centralManager.scanForPeripherals(withServices: [ParticlePeripheral.particlePeripheralServiceUUID],
                                                              options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
        @unknown default:
            break
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        self.centralManager.stopScan()
        self.peripheral = peripheral
        self.peripheral.delegate = self
        
        self.centralManager.connect(self.peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if peripheral == self.peripheral {
            print("peripheral connected!")
            peripheral.discoverServices([ParticlePeripheral.particlePeripheralServiceUUID])
            
        }
    }
    
}

extension BluetoothCentral: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                if service.uuid == ParticlePeripheral.particlePeripheralServiceUUID {
                    print("device found")
                    peripheral.discoverCharacteristics([ParticlePeripheral.particleSliderCharacteristicUUID, ParticlePeripheral.particleSlider2CharacteristicUUID], for: service)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.uuid == ParticlePeripheral.particleSliderCharacteristicUUID {
                    self.characteristic = characteristic
                    self.peripheral.setNotifyValue(true, for: characteristic)
                }
                
                if characteristic.uuid == ParticlePeripheral.particleSlider2CharacteristicUUID {
                    self.characteristic2 = characteristic
                    self.peripheral.setNotifyValue(true, for: characteristic2)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print(characteristic)
        print(peripheral.readValue(for: characteristic))
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            print(error as Any)
            return
        }
        if characteristic.uuid == ParticlePeripheral.particleSliderCharacteristicUUID {
            let v = String(data: characteristic.value!, encoding: .unicode)
            self.delegate.slider.setValue((v! as NSString).floatValue, animated: false)
        } else if characteristic.uuid == ParticlePeripheral.particleSlider2CharacteristicUUID {
            let v = String(data: characteristic.value!, encoding: .unicode)
            self.delegate.slider2.setValue((v! as NSString).floatValue, animated: false)
        }
        
    }
}

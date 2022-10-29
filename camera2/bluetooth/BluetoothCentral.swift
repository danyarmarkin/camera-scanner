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
    var peripheralDevides: [PeripheralDevice]! = []
    var delegate: ViewController!
    
    func configure(delegate: ViewController) {
        self.delegate = delegate
        centralManager = CBCentralManager(delegate: self, queue: nil)
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

        
        if self.peripherals().contains(peripheral) {
            return
        }
        
        if ["12 max", "13 mini"].contains(peripheral.name ?? "") {
            let pd = PeripheralDevice()
            pd.peripheral = peripheral
            self.peripheralDevides.append(pd)
            peripheral.delegate = self
            
            self.centralManager.connect(peripheral)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if self.peripherals().contains(peripheral) {
            print("peripheral connected!")
            peripheral.discoverServices([ParticlePeripheral.particlePeripheralServiceUUID])
            
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("disconected: \(String(describing: peripheral.name))")
        
        for i in 0...peripheralDevides.count - 1 {
            if peripheralDevides[i].peripheral == peripheral {
                peripheralDevides.remove(at: i)
                break
            }
        }
    }
    
}

extension BluetoothCentral: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                print((service.peripheral?.name ?? "undefined") as String)
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
                let pd = getPeripheralDevice(peripheral)
                if characteristic.uuid == ParticlePeripheral.particleSliderCharacteristicUUID {
                    pd.characteristic = characteristic
                    pd.peripheral?.setNotifyValue(true, for: characteristic)
                }
                
                if characteristic.uuid == ParticlePeripheral.particleSlider2CharacteristicUUID {
                    pd.characteristic2 = characteristic
                    pd.peripheral?.setNotifyValue(true, for: characteristic)
                }
            }
        }
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            print(error as Any)
            return
        }
        if characteristic.uuid == ParticlePeripheral.particleSliderCharacteristicUUID {
            let v = String(data: characteristic.value!, encoding: .unicode)
            for pd in peripheralDevides {
                if pd.peripheral == peripheral || pd.characteristic == nil { continue }
                pd.peripheral?.writeValue(characteristic.value!, for: pd.characteristic!, type: .withoutResponse)
            }
            self.delegate.slider.setValue((v! as NSString).floatValue, animated: false)
        } else if characteristic.uuid == ParticlePeripheral.particleSlider2CharacteristicUUID {
            let v = String(data: characteristic.value!, encoding: .unicode)
            for pd in peripheralDevides {
                if pd.peripheral == peripheral || pd.characteristic2 == nil { continue }
                pd.peripheral?.writeValue(characteristic.value!, for: pd.characteristic2!, type: .withoutResponse)
            }
            self.delegate.slider2.setValue((v! as NSString).floatValue, animated: false)
        }
        
    }
}

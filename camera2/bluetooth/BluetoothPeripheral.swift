//
//  PeripheralCentral.swift
//  bluetooth
//
//  Created by Данила Ярмаркин on 29.09.2022.
//

import Foundation
import CoreBluetooth

class BluetoothPeripheral: NSObject {
    
    var peripheralManager: CBPeripheralManager!
    var characteristic: CBMutableCharacteristic!
    var characteristic2: CBMutableCharacteristic!
    
    var delegate: ViewController!
    
    func configure(delegate: ViewController) {
        self.delegate = delegate
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
}

extension BluetoothPeripheral: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .poweredOn:
            // ... so start working with the peripheral
            print("CBManager is powered on")
            
            let transferCharacteristic = CBMutableCharacteristic(type: ParticlePeripheral.particleSliderCharacteristicUUID, properties: [.notify, .read, .writeWithoutResponse], value: nil, permissions: [.readable, .writeable])
            
            let transferCharacteristic2 = CBMutableCharacteristic(type: ParticlePeripheral.particleSlider2CharacteristicUUID, properties: [.notify, .read, .writeWithoutResponse], value: nil, permissions: [.readable, .writeable])
            
            let transferService = CBMutableService(type: ParticlePeripheral.particlePeripheralServiceUUID, primary: true)
            transferService.characteristics = [transferCharacteristic, transferCharacteristic2]
            self.characteristic = transferCharacteristic
            self.characteristic2 = transferCharacteristic2
            peripheralManager.add(transferService)
            
            peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [ParticlePeripheral.particlePeripheralServiceUUID]])
            
        case .poweredOff:
            print("CBManager is not powered on")
            // In a real app, you'd deal with all the states accordingly
            return
        case .resetting:
            print("CBManager is resetting")
            // In a real app, you'd deal with all the states accordingly
            return
        case .unauthorized:
            print("unathorized")
        case .unknown:
            print("CBManager state is unknown")
            // In a real app, you'd deal with all the states accordingly
            return
        case .unsupported:
            print("Bluetooth is not supported on this device")
            // In a real app, you'd deal with all the states accordingly
            return
        @unknown default:
            print("A previously unknown peripheral manager state occurred")
            // In a real app, you'd deal with yet unknown cases that might occur in the future
            return
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        if service.uuid == ParticlePeripheral.particlePeripheralServiceUUID {
            print("add")
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        print(characteristic.uuid)
        print("\(central.description) subscribed")
        peripheral.updateValue("0.5".data(using: .unicode)!, for: self.characteristic, onSubscribedCentrals: nil)
        peripheral.updateValue("0.5".data(using: .unicode)!, for: self.characteristic2, onSubscribedCentrals: nil)
        peripheralManager.setDesiredConnectionLatency(.low, for: central)
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        print("write")
        for request in requests {
            let v = String(data: request.value!, encoding: .unicode)
            
            switch request.characteristic.uuid {
            case ParticlePeripheral.particleSliderCharacteristicUUID:
                self.delegate.slider.setValue((v! as NSString).floatValue, animated: false)
                break
            case ParticlePeripheral.particleSlider2CharacteristicUUID:
                self.delegate.slider2.setValue((v! as NSString).floatValue, animated: false)
                break
            default:
                break
            }
            
            peripheral.respond(to: request, withResult: .success)
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        print("read")
    }
    
}


//
//  ViewController.swift
//  bluetooth_peripheral
//
//  Created by Данила Ярмаркин on 12.09.2022.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController {
    

    @IBOutlet weak var slider: UISlider!
    
    var peripheralManager: CBPeripheralManager!
    var characteristic: CBMutableCharacteristic!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }

    @IBAction func onSlider(_ sender: UISlider) {
        peripheralManager.updateValue("\(sender.value)".data(using: .unicode)!, for: characteristic!, onSubscribedCentrals: nil)
    }
    
}

extension ViewController: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .poweredOn:
            // ... so start working with the peripheral
            print("CBManager is powered on")
            
            let transferCharacteristic = CBMutableCharacteristic(type: ParticlePeripheral.particleSliderCharacteristicUUID, properties: [.notify, .write, .read, .writeWithoutResponse], value: nil, permissions: [.readable, .writeable])
            
            let transferService = CBMutableService(type: ParticlePeripheral.particlePeripheralServiceUUID, primary: true)
            transferService.characteristics = [transferCharacteristic]
            self.characteristic = transferCharacteristic
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
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        for request in requests {
            let v = String(data: request.value!, encoding: .unicode)
            slider.setValue((v! as NSString).floatValue, animated: false)
//            peripheral.respond(to: request, withResult: .success)
        }
        print("write")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        print("read")
    }
}

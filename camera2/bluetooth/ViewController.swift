//
//  ViewController.swift
//  bluetooth
//
//  Created by Данила Ярмаркин on 31.08.2022.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController {

    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var switcher: UISegmentedControl!
    
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    @IBAction func slide(_ sender: UISlider) {
    }
    
    
    @IBAction func `switch`(_ sender: UISegmentedControl) {
    }
}

extension ViewController: CBCentralManagerDelegate {
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

extension ViewController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                if service.uuid == ParticlePeripheral.particlePeripheralServiceUUID {
                    print("device found")
                    peripheral.discoverCharacteristics([ParticlePeripheral.particleSliderCharacteristicUUID], for: service)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.uuid == ParticlePeripheral.particleSliderCharacteristicUUID {
                    self.peripheral.setNotifyValue(true, for: characteristic)
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
            print("value upadeted")
            print(characteristic)
            let v = String(data: characteristic.value!, encoding: .unicode)
            slider.setValue((v as! NSString).floatValue, animated: false)
        }
        
    }
}

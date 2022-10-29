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
    @IBOutlet weak var slider2: UISlider!
    @IBOutlet weak var switcher: UISegmentedControl!
    
    var bluetoothCentral: BluetoothCentral!
    var bluetoothPeripheral: BluetoothPeripheral!
    var bluetoothStatus: BluetoothStatus!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bluetoothStatus = .central
        bluetoothCentral = BluetoothCentral()
        bluetoothCentral.configure(delegate: self)
    }
    
    @IBAction func slide(_ sender: UISlider) {
        let data = "\(sender.value)".data(using: .unicode)!
        switch bluetoothStatus {
        case .central:
            for pd in bluetoothCentral.peripheralDevides {
                pd.peripheral?.writeValue(data, for: pd.characteristic!, type: .withoutResponse)
            }
        case .peripheral:
            if bluetoothPeripheral.peripheralManager != nil {
                bluetoothPeripheral.peripheralManager.updateValue(data, for: bluetoothPeripheral.characteristic, onSubscribedCentrals: nil)
            }
        case .none:
            break
        }
        
        
    }
    
    @IBAction func slide2(_ sender: UISlider) {
        let data = "\(sender.value)".data(using: .unicode)!
        switch bluetoothStatus {
        case .central:
            for pd in bluetoothCentral.peripheralDevides {
                pd.peripheral?.writeValue(data, for: pd.characteristic2!, type: .withoutResponse)
            }
        case .peripheral:
            if bluetoothPeripheral.peripheralManager != nil {
                bluetoothPeripheral.peripheralManager.updateValue(data, for: bluetoothPeripheral.characteristic2, onSubscribedCentrals: nil)
            }
        case .none:
            break
        }
    }
    
    @IBAction func `switch`(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 1 {
            bluetoothStatus = .peripheral
            bluetoothCentral = nil
            bluetoothPeripheral = BluetoothPeripheral()
            bluetoothPeripheral.configure(delegate: self)
        } else {
            bluetoothStatus = .central
            bluetoothPeripheral = nil
            bluetoothCentral = BluetoothCentral()
            bluetoothCentral.configure(delegate: self)
        }
    }
}


enum BluetoothStatus {
    case central
    case peripheral
}

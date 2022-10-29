//
//  PeripheralDevice.swift
//  camera2
//
//  Created by Данила Ярмаркин on 04.10.2022.
//

import Foundation
import CoreBluetooth

class PeripheralDevice {
    var isoCharacteristic: CBCharacteristic? = nil
    var shutterCharacteristic: CBCharacteristic? = nil
    var wbCharacteristic: CBCharacteristic? = nil
    var tintCharacteristic: CBCharacteristic? = nil
    var fpsCharacteristic: CBCharacteristic? = nil
    
    var sessionNameCharacteristic: CBCharacteristic? = nil
    var sessionObjectCharacteristic: CBCharacteristic? = nil
    var isStartCharacteristic: CBCharacteristic? = nil
    var nameMaskCharacteristic: CBCharacteristic? = nil
    var serialIndexCharacteristic: CBCharacteristic? = nil
    
    var batteryCharacteristic: CBCharacteristic? = nil
    var storageCharacteristic: CBCharacteristic? = nil
    var totalStorageCharacteristic: CBCharacteristic? = nil
    var isChargingCharacteristic: CBCharacteristic? = nil
    
    var devicesCharacteristic: CBCharacteristic? = nil
    
    var peripheral: CBPeripheral? = nil
}


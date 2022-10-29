//
//  PeripheralDevice.swift
//  bluetooth
//
//  Created by Данила Ярмаркин on 01.10.2022.
//

import Foundation
import CoreBluetooth

class PeripheralDevice {
    var characteristic: CBCharacteristic? = nil
    var characteristic2: CBCharacteristic? = nil
    var peripheral: CBPeripheral? = nil
}

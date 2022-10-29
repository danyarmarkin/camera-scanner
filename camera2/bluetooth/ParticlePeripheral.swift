//
//  ParticalPeripheral.swift
//  bluetooth
//
//  Created by Данила Ярмаркин on 10.09.2022.
//

import Foundation
import CoreBluetooth

class ParticlePeripheral: NSObject {
    public static let particlePeripheralServiceUUID = CBUUID(string: "b4250400-fb4b-4746-b2b0-93f0e61122c6")
    public static let particleSliderCharacteristicUUID = CBUUID(string: "b4250401-fb4b-4746-b2b0-93f0e61122c6")
    public static let particleSlider2CharacteristicUUID = CBUUID(string: "b4250402-fb4b-4746-b2b0-93f0e61122c6")
}

//
//  BluetoothConstants.swift
//  camera2
//
//  Created by Данила Ярмаркин on 04.10.2022.
//

import Foundation

import CoreBluetooth

class BluetoothConstants: NSObject {
    public static let service = CBUUID(string: "14fe202a-41a9-4589-8306-516e5e9f5214")
    
    public static let iso = CBUUID(string: "64b173d5-8b54-41a4-964f-0901fdfcf68f")
    public static let shutter = CBUUID(string: "2c48e105-c62b-47ae-9426-8ce56ea68fc9")
    public static let wb = CBUUID(string: "a77203b8-797d-429f-9e27-22cc7b15e056")
    public static let tint = CBUUID(string: "31643a4c-e747-43ca-9824-68c0f15b5c18")
    public static let fps = CBUUID(string: "93dcf812-66f7-402b-8215-a804423e8f67")
    
    public static let sessionName = CBUUID(string: "94d37290-b005-4ac1-8cfe-598426a1122f")
    public static let sessionObject = CBUUID(string: "a1ea6edd-ab00-4670-a007-c57645c5004c")
    public static let isStart = CBUUID(string: "4ec8731f-2c68-4bc4-b2b0-4b81acf33273")
    public static let nameMask = CBUUID(string: "08dc4c90-7b0d-4b75-a76b-ad478e5a823c")
    public static let serialIndex = CBUUID(string: "dcc64a4b-10ad-429d-a604-c27f1e7ff892")
    
    public static let devices = CBUUID(string: "317d1163-e3c7-4e88-8cd5-d59040c21357")
    
    public static let battery = CBUUID(string: "08ea9461-43db-4ac8-a519-36378201fa6e")
    public static let storage = CBUUID(string: "e2cc73c1-ec79-4965-b8eb-95de479f646b")
    public static let totalStorage = CBUUID(string: "0d463799-51f5-403f-b6f5-b7ed912621ae")
    public static let isCharging = CBUUID(string: "e0ad83dc-9af4-4474-b256-bf20bbb5feb0")
    
    public static let characteristics = [iso, shutter, wb, tint, fps, sessionName, sessionObject, isStart, nameMask, serialIndex, battery, storage, totalStorage, isCharging, devices]
}

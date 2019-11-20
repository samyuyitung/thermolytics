//
//  ScannedPeripheral.swift
//  nRF Toolbox
//
//  Created by Mostafa Berg on 28/04/16.
//  Copyright © 2016 Nordic Semiconductor. All rights reserved.
//

import UIKit
import CoreBluetooth

struct ScannedPeripheral: Equatable {
    
    var peripheral: CBPeripheral
    var RSSI: Int32 = 0
    var isConnected: Bool
    
    func name() -> String {
        return peripheral.name ?? "Unnamed"
    }
    
    static func == (lhs: ScannedPeripheral, rhs: Any?) -> Bool {
        if let other = rhs as? ScannedPeripheral {
            return lhs.peripheral == other.peripheral
        }
        return false
    }
}

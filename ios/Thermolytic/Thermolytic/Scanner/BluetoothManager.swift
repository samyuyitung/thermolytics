//
//  BluetoothManager.swift
//  nRF Toolbox
//
//  Created by Mostafa Berg on 06/05/16.
//  Copyright © 2016 Nordic Semiconductor. All rights reserved.
//

import UIKit
import CoreBluetooth

protocol BluetoothManagerDelegate {
    func didConnectPeripheral(deviceName aName : String?)
    func didDisconnectPeripheral()
    func peripheralReady()
    func peripheralNotSupported()
    func didReceive(message: String)
    func didSend(message: String)
}

class BluetoothManager: NSObject, CBPeripheralDelegate, CBCentralManagerDelegate {
    
    //MARK: - Delegate Properties
    var delegate : BluetoothManagerDelegate?
//    var logger   : Logger?
    
    //MARK: - Class Properties
    fileprivate let UARTServiceUUID = CBUUID(string: ServiceIdentifiers.uartServiceUUIDString)
    fileprivate let UARTTXCharacteristicUUID = CBUUID(string: ServiceIdentifiers.uartTXCharacteristicUUIDString)
    fileprivate let UARTRXCharacteristicUUID = CBUUID(string: ServiceIdentifiers.uartRXCharacteristicUUIDString)
    
    fileprivate var centralManager              : CBCentralManager
    fileprivate var bluetoothPeripheral         : CBPeripheral?
    fileprivate var uartRXCharacteristic        : CBCharacteristic?
    fileprivate var uartTXCharacteristic        : CBCharacteristic?
    
    var connected = false
    
    //MARK: - BluetoothManager API
    
    required init(withManager aManager : CBCentralManager) {
        centralManager = aManager
        super.init()
        
        centralManager.delegate = self
    }
    
    /**
     * Connects to the given peripheral.
     * 
     * - parameter aPeripheral: target peripheral to connect to
     */
    func connectPeripheral(peripheral: CBPeripheral) {
        bluetoothPeripheral = peripheral
        centralManager.connect(peripheral, options: nil)
    }
    
    /**
     * Disconnects or cancels pending connection.
     * The delegate's didDisconnectPeripheral() method will be called when device got disconnected.
     */
    func cancelPeripheralConnection() {
        guard bluetoothPeripheral != nil else {
            return
        }
        centralManager.cancelPeripheralConnection(bluetoothPeripheral!)
        
        // In case the previous connection attempt failed before establishing a connection
        if !connected {
            bluetoothPeripheral = nil
            delegate?.didDisconnectPeripheral()
        }
    }
    
    /**
     * This method sends the given test to the UART RX characteristic.
     * Depending on whether the characteristic has the Write Without Response or Write properties the behaviour is different.
     * In the latter case the Long Write may be used. To enable it you have to change the flag below in the code.
     * Otherwise, in both cases, texts longer than 20 (MTU) bytes (not characters) will be splitted into up-to 20-byte packets.
     *
     * - parameter aText: text to be sent to the peripheral using Nordic UART Service
     */
    func send(text aText : String) {
        guard let uartRXCharacteristic = uartRXCharacteristic else {
            return
        }
        
        // Check what kind of Write Type is supported. By default it will try Without Response.
        // If the RX charactereisrtic have Write property the Write Request type will be used.
        
        let writeable = uartRXCharacteristic.properties.contains(.write)
        let type: CBCharacteristicWriteType = writeable ? .withResponse : .withoutResponse
        let MTU = bluetoothPeripheral?.maximumWriteValueLength(for: type) ?? 20
        
        // The following code will split the text into packets
        aText.split(by: MTU).forEach {
            send(text: $0, type: type)
        }
    }
    
    /**
     * Sends the given text to the UART RX characteristic using the given write type.
     * This method does not split the text into parts. If the given write type is withResponse
     * and text is longer than 20-bytes the long write will be used.
     *
     * - parameters:
     *     - aText: text to be sent to the peripheral using Nordic UART Service
     *     - aType: write type to be used
     */
    func send(text: String, type: CBCharacteristicWriteType) {
        guard let uartRXCharacteristic = uartRXCharacteristic else {
            return
        }
        
        let data = text.data(using: String.Encoding.utf8)!
        
        // Do some logging
        bluetoothPeripheral!.writeValue(data, for: uartRXCharacteristic, type: type)
        delegate?.didSend(message: text)
    }
    
    //MARK: - Logger API
    
    func logError(error anError : Error) {
//        if let e = anError as? CBError {
//            logger?.log(level: .errorLogLevel, message: "Error \(e.code): \(e.localizedDescription)")
//        } else {
//            logger?.log(level: .errorLogLevel, message: "Error \(anError.localizedDescription)")
//        }
    }
    
    //MARK: - CBCentralManagerDelegate
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {

    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connected = true
        bluetoothPeripheral = peripheral
        bluetoothPeripheral!.delegate = self
        delegate?.didConnectPeripheral(deviceName: peripheral.name)
        peripheral.discoverServices([UARTServiceUUID])
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        guard error == nil else {
            return
        }
        reset()
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        guard error == nil else {
            return
        }
        reset()
    }
    
    func reset() {
        connected = false
        delegate?.didDisconnectPeripheral()
        bluetoothPeripheral!.delegate = nil
        bluetoothPeripheral = nil
    }
    
    //MARK: - CBPeripheralDelegate
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil else {
            //TODO: Disconnect?
            return
        }
        
        if let services = peripheral.services {
            for service in services {
                if service.uuid.isEqual(UARTServiceUUID) {
                    bluetoothPeripheral!.discoverCharacteristics(nil, for: service)
                    return
                }
            }
            delegate?.peripheralNotSupported()
            cancelPeripheralConnection()
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard error == nil else {
            return
        }
        
        if service.uuid.isEqual(UARTServiceUUID), let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.uuid.isEqual(UARTTXCharacteristicUUID) {
                    uartTXCharacteristic = characteristic
                } else if characteristic.uuid.isEqual(UARTRXCharacteristicUUID) {
                    uartRXCharacteristic = characteristic
                }
            }
            //Enable notifications on TX Characteristic
            if (uartTXCharacteristic != nil && uartRXCharacteristic != nil) {
                bluetoothPeripheral!.setNotifyValue(true, for: uartTXCharacteristic!)
            } else {
                delegate?.peripheralNotSupported()
                cancelPeripheralConnection()
            }
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            return
        }
        
        // try to print a friendly string of received bytes if they can be parsed as UTF8
        guard let bytesReceived = characteristic.value else {
            return
        }
        
        if let message = String(data: bytesReceived, encoding: .utf8) {
            let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
            delegate?.didReceive(message: trimmed)
        } else {
            delegate?.didReceive(message: bytesReceived.hexString)
        }
    }
}

private extension String {
    func split(by length: Int) -> [String] {
        var startIndex = self.startIndex
        var results = [Substring]()
        
        while startIndex < endIndex {
            let endIndex = index(startIndex, offsetBy: length, limitedBy: self.endIndex) ?? self.endIndex
            results.append(self[startIndex..<endIndex])
            startIndex = endIndex
        }
        
        return results.map { String($0) }
    }
    
}

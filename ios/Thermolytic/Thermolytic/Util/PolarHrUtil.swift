//
//  PolarHrUtil.swift
//  Thermolytic
//
//  Created by Sam Yuyitung on 2020-02-04.
//  Copyright © 2020 Sam Yuyitung. All rights reserved.
//

import Foundation
import PolarBleSdk

class PolarHrUtil {

    var isConnected = false
    private var lastHr: Int? = nil
    
    func getLastHr() -> Double? {
        if isConnected, let hr = lastHr {
            return Double(hr)
        }
        return nil
    }
    
    fileprivate static let DEVICE_ID = "59A9F325"
    var api = PolarBleApiDefaultImpl.polarImplementation(DispatchQueue.main, features: Features.allFeatures.rawValue)

    init() {
        connectTo()
        api.deviceHrObserver = self
        api.observer = self
    }

    func connectTo(device: String = DEVICE_ID) {
        do{
            try api.connectToDevice(device)
        } catch let err {
            Utils.log(at: .Error, msg: err.localizedDescription)
        }
    }
    
    func disconnectFrom(device: String = DEVICE_ID) {
        do{
            try api.disconnectFromDevice(device)
        } catch let err {
            Utils.log(at: .Error, msg: err.localizedDescription)
        }
    }
}

extension PolarHrUtil: PolarBleApiObserver {
    func deviceConnecting(_ polarDeviceInfo: PolarDeviceInfo) {
        Utils.log(msg: "DEVICE CONNECTING: \(polarDeviceInfo)")
    }
    
    func deviceConnected(_ polarDeviceInfo: PolarDeviceInfo) {
        Utils.log(msg: "DEVICE CONNECTED: \(polarDeviceInfo)")
        isConnected = true
    }
    
    func deviceDisconnected(_ polarDeviceInfo: PolarDeviceInfo) {
        Utils.log(msg: "DISCONNECTED: \(polarDeviceInfo)")
        isConnected = false
    }
}

extension PolarHrUtil: PolarBleApiDeviceHrObserver {
    func hrValueReceived(_ identifier: String, data: PolarHrData) {
        lastHr = Int(data.hr)
//        Utils.log(msg: "last HR \(lastHr)")
    }
}

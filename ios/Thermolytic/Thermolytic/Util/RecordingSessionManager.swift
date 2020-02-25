//
//  RecordingSessionManager.swift
//  Thermolytic
//
//  Created by Sam Yuyitung on 2020-02-12.
//  Copyright © 2020 Sam Yuyitung. All rights reserved.
//

import UIKit
import CoreBluetooth

protocol RecordingSessionDeviceDelegate {
    func didUpdateDevices()
}

class RecordingSessionManager {
    let DEVICE_FILTER_TIME = 30.0
    
    @objc func purge() {
        devices = devices.filter { (key: String, time: TimeInterval) -> Bool in
            let old = Date(timeIntervalSinceReferenceDate: time)
            return Date().timeIntervalSince(old) < DEVICE_FILTER_TIME
        }
    }
    
    var timer: Timer?
    init() {
        self.timer = Timer.scheduledTimer(timeInterval  : 30.0, target: self, selector: #selector(self.purge), userInfo: nil, repeats: true)
    }
    
    var devicesDelegate:RecordingSessionDeviceDelegate? = nil
    
    static let shared = RecordingSessionManager()
    
    var bluetoothManager: BluetoothManager? = nil
    var hrManager : PolarHrUtil = PolarHrUtil()
    
    var devices: [String : TimeInterval] = [:] {
        didSet {
            devicesDelegate?.didUpdateDevices()
        }
    }
    var participants: [String:String] = [:]
    
    func getAllDevices() -> [String] {
        return Array(devices.keys)
    }
    
    func configure(manager: CBCentralManager, peripheral: CBPeripheral) {
       bluetoothManager = BluetoothManager(withManager: manager)
       bluetoothManager!.connectPeripheral(peripheral: peripheral)
       bluetoothManager!.delegate = self
    }
    
    func addParticipant(uid: String, deviceId: String) -> Bool {
        if let _ = participants.first(where: { (key: String, value: String) -> Bool in
            return key == uid || value == deviceId
        }){
            return false
        }
        participants[uid] = deviceId
        return true
    }
    
    func getAthleteBy(deviceId: String) -> String? {
        let entry = participants.first { (key: String, value: String) -> Bool in
            return value == deviceId
        }
        return entry?.key
    }
    
    func getDeviceBy(uid: String) -> String? {
        let entry = participants.first { (key: String, value: String) -> Bool in
            return key == uid
        }
        return entry?.value
    }
}

extension RecordingSessionManager: BluetoothManagerDelegate {
    
    func didReceive(message: String) {
        let parts = message.components(separatedBy: ",")

        let deviceId = parts[0]
        devices[deviceId] = Date().timeIntervalSinceReferenceDate
        
        Utils.log(msg: message)
        
    }
    
    func didSend(message: String) {
        // Unused
    }
    
    func didConnectPeripheral(deviceName aName: String?) {
        // Unused
    }
    
    func didDisconnectPeripheral() {
        // Scanner uses other queue to send events. We must edit UI in the main queue
        DispatchQueue.main.async {
            self.bluetoothManager = nil
        }
        bluetoothManager = nil
    }
    
    func saveDocument() {
//        let parts = message.components(separatedBy: ",")
//        
//        // <d_id>,<arm_t>,<leg_t>,<am_t>,<am_h>
//        Utils.log(at: .Debug, msg: "\(message)")
//
//        guard parts.count == 5 else {
//            Utils.log(at: .Error, msg: "Bad transmission, Not opening")
//            return
//        }
//        
//        let deviceId = parts[0]
//        
//        let uid = RecordingSessionManager.shared.participants[deviceId]
//        
//        let armTemperature = Double(parts[1])!
//        let legTemperature = Double(parts[2])!
//        let ambientTemperature = 1.2 // Double(parts[3])!
//        let ambientHumidity = 1.2 //Double(parts[4])! / 100.0
//        
//        let averageSkinTemp = (armTemperature + legTemperature) / 2
//        
//        if let heartRate = hrManager.getLastHr() {
//            Utils.log(msg: "\(user.toDictionary() as AnyObject)")
//            let weight = user.double(forKey: Athlete.weight.key)
//            let coreTemp = TwoNode.getCoreTemp(mass_body: weight,
//                                               temp_skin_avg: averageSkinTemp,
//                                               heart_rate_rest: 60,
//                                               heart_rate: heartRate,
//                                               rel_humidity: ambientHumidity,
//                                               temp_air: ambientTemperature)
//            
//            if let doc = BioFrame.create(uid: user.string(forKey: BioFrame.uid.key)!,
//                                         heartRate: Int(heartRate),
//                                         armSkinTemp: armTemperature,
//                                         legSkinTemp: legTemperature,
//                                         avgSkinTemp: averageSkinTemp,
//                                         ambientTemp: ambientTemperature,
//                                         ambientHumidity: ambientHumidity,
//                                         predictedCoreTemp: coreTemp) {
//                addToDatabase(document: doc)
//            } else {
//                Utils.log(at: .Warning, msg: "Could not create frame for \(message)")
//            }
//            DatabaseUtil.insert(doc: document)
//        }
    }
}


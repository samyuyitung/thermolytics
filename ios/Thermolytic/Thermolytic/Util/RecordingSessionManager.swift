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

protocol RecordingSessionDelegate {
    func didStartSession(named: String)
    func didStopSession()
    func didUpdateParticipants()
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
    
    var devicesDelegate: RecordingSessionDeviceDelegate? = nil
    var delegate: RecordingSessionDelegate? = nil
    
    static let shared = RecordingSessionManager()
    
    var bluetoothManager: BluetoothManager? = nil
    var hrManager : PolarHrUtil = PolarHrUtil()
    
    var devices: [String : TimeInterval] = [:] {
        didSet {
            devicesDelegate?.didUpdateDevices()
        }
    }
    var participants: [String:String] = [:] { // UID, device id
        didSet {
            devicesDelegate?.didUpdateDevices() // Cheat to update Devices table
            delegate?.didUpdateParticipants()
        }
    }
    
    var activePlayers: [String] = [] // UID
    var benchPlayers: [String] = [] // UID
    
    var isRecording = false
    var sessionName: String? = nil
    
    func startSession(named name: String) {
        guard !isRecording else {
            return
        }
        isRecording = true
        sessionName = name
        delegate?.didStartSession(named: name)
    }
    
    func stopSession() {
        guard isRecording else {
            return
        }
        isRecording = false
        sessionName = nil
        delegate?.didStopSession()
    }
    
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
        benchPlayers.append(uid)
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
        
        let deviceId = parts[1]
        devices[deviceId] = Date().timeIntervalSinceReferenceDate
        
        saveDocument(with: message)
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
    
    func saveDocument(with message: String) {
        Utils.log(at: .Debug, msg: "\(message)")
        guard isRecording else {
            return
        }
        
        let parts = message.components(separatedBy: ",")
        
        //1,<d_id>,<arm>,<leg>,imu_x,imu_y,<amb_t>,<amb_h>
        guard parts.count == 8 else {
            Utils.log(at: .Error, msg: "Bad transmission, Not opening")
            return
        }
        
        let deviceId = parts[1]
        let armTemperature = Double(parts[2]) ?? BioFrame.missingDefault
        let legTemperature = Double(parts[3]) ?? BioFrame.missingDefault
        let imuX = Double(parts[4]) ?? BioFrame.missingDefault
        let imuY = Double(parts[5]) ?? BioFrame.missingDefault
        let ambientTemperature = Double(parts[6])!
        let ambientHumidity = Double(parts[7])! / 100
        
        let averageSkinTemp = (armTemperature + legTemperature) / 2

        guard averageSkinTemp > 0 else {
            Utils.log(at: .Error, msg: "Negative temperature for message \(message)")
            return
        }
//
        if let heartRate = hrManager.getLastHr(),
            let uid = getAthleteBy(deviceId: deviceId),
            let user = DatabaseUtil.shared.document(withID: uid),
            let sessionName = sessionName {
            
            let weight = user.double(forKey: Athlete.weight.key)
            let coreTemp = TwoNode.getCoreTemp(mass_body: weight,
                                               temp_skin_avg: averageSkinTemp,
                                               heart_rate_rest: 60,
                                               heart_rate: heartRate,
                                               rel_humidity: ambientHumidity,
                                               temp_air: ambientTemperature)
            
            if let doc = BioFrame.create(deviceId: deviceId,
                                         uid: uid,
                                         heartRate: Int(heartRate),
                                         armSkinTemp: armTemperature,
                                         legSkinTemp: legTemperature,
                                         avgSkinTemp: averageSkinTemp,
                                         xAcceleration: imuX,
                                         yAcceleration: imuY,
                                         ambientTemp: ambientTemperature,
                                         ambientHumidity: ambientHumidity,
                                         predictedCoreTemp: coreTemp,
                                         session: sessionName) {
                let _ = DatabaseUtil.insert(doc: doc)
            } else {
                Utils.log(at: .Warning, msg: "Could not create frame for \(message)")
            }
        } else {
            Utils.log(msg: "Did not log for message \(message)")
        }
    }
}


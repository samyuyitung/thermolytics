//
//  ScannerViewController.swift
//  nRF Toolbox
//
//  Created by Mostafa Berg on 28/04/16.
//  Copyright © 2016 Nordic Semiconductor. All rights reserved.
//

import UIKit
import CoreBluetooth

// TODO: Split into extensions? 
class ScannerViewController: UIViewController, CBCentralManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    let dfuServiceUUIDString  = "00001530-1212-EFDE-1523-785FEABCD123"
    let ANCSServiceUUIDString = "7905F431-B5CE-4E99-A40F-4B1E122D00D0"
    
    //MARK: - ViewController Properties
    var bluetoothManager : CBCentralManager?
    var filterUUID : CBUUID?
//    var peripherals : [ScannedPeripheral] = []
    
    @IBOutlet weak var sensorsTable: UITableView!
    
    func getConnectedPeripherals() -> [CBPeripheral] {
        guard let bluetoothManager = bluetoothManager else {
            return []
        }
        
        var retreivedPeripherals : [CBPeripheral]
        
        if filterUUID == nil {
            let dfuServiceUUID = CBUUID(string: dfuServiceUUIDString)
            let ancsServiceUUID = CBUUID(string: ANCSServiceUUIDString)
            retreivedPeripherals = bluetoothManager.retrieveConnectedPeripherals(withServices: [dfuServiceUUID, ancsServiceUUID])
        } else {
            retreivedPeripherals = bluetoothManager.retrieveConnectedPeripherals(withServices: [filterUUID!])
        }
        
        return retreivedPeripherals
    }
    
    /**
     * Starts scanning for peripherals with rscServiceUUID.
     * - parameter enable: If YES, this method will enable scanning for bridge devices, if NO it will stop scanning
     * - returns: true if success, false if Bluetooth Manager is not in CBCentralManagerStatePoweredOn state.
     */
    func scanForPeripherals(_ enable:Bool) -> Bool {
        guard bluetoothManager?.state == .poweredOn else {
            return false
        }
        
        DispatchQueue.main.async {
            if enable == true {
                let options: NSDictionary = NSDictionary(objects: [NSNumber(value: true as Bool)], forKeys: [CBCentralManagerScanOptionAllowDuplicatesKey as NSCopying])
                if self.filterUUID != nil {
                    self.bluetoothManager?.scanForPeripherals(withServices: [self.filterUUID!], options: options as? [String : AnyObject])
                } else {
                    self.bluetoothManager?.scanForPeripherals(withServices: nil, options: options as? [String : AnyObject])
                }
            } else {
                self.bluetoothManager?.stopScan()
            }
        }
        
        return true
    }
    
    //MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        for tableView in [sensorsTable] {
            tableView?.delegate = self
            tableView?.dataSource = self
        }
        
        RecordingSessionManager.shared.devicesDelegate = self
        
        let activityIndicatorView              = UIActivityIndicatorView(style: .gray)
        activityIndicatorView.hidesWhenStopped = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicatorView)
        
        activityIndicatorView.startAnimating()
        
        let centralQueue = DispatchQueue(label: "no.nordicsemi.nRFToolBox", attributes: [])
        bluetoothManager = CBCentralManager(delegate: self, queue: centralQueue)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPlayers" {
            let cell = sender as! UITableViewCell
            let device = cell.textLabel?.text?.components(separatedBy: " ")[0]
            
            let vc = segue.destination as! SelectPlayerViewController
            vc.deviceId = device
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        let success = self.scanForPeripherals(false)
        if !success {
            print("Bluetooth is powered off!")
        }
        
        super.viewWillDisappear(animated)
    }
    
    //MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RecordingSessionManager.shared.devices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let aCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let device = RecordingSessionManager.shared.getAllDevices()[indexPath.row]
        
        if let uid = RecordingSessionManager.shared.getAthleteBy(deviceId: device),
            let userDoc = DatabaseUtil.shared.document(withID: uid) {
            aCell.textLabel?.text = "\(device) -- \(userDoc.string(forKey: Athlete.name.key) ?? "no name?")"
        } else {
            aCell.textLabel?.text = "\(device) -- unclaimed"
        }
        return aCell
    }
    
    //MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showPlayers", sender: tableView.cellForRow(at: indexPath))
    }
    
    //MARK: - CBCentralManagerDelgate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        guard central.state == .poweredOn else {
            print("Bluetooth is porewed off")
            return
        }
        
        let success = self.scanForPeripherals(true)
        if !success {
            print("Bluetooth is powered off!")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // Only deal with named peripherals
        guard peripheral.name == "raspberrypi" else {
            return
        }
        bluetoothManager!.stopScan()
        RecordingSessionManager.shared.configure(manager: bluetoothManager!, peripheral: peripheral)
        
        // Scanner uses other queue to send events. We must edit UI in the main queue
//        DispatchQueue.main.async {
//            var sensor = ScannedPeripheral(peripheral: peripheral, RSSI: RSSI.int32Value, isConnected: false)
//            if let index = self.peripherals.firstIndex(where: { existing -> Bool in
//                return existing.peripheral == sensor.peripheral
//            }) {
//                sensor = self.peripherals[index]
//            } else {
//                self.peripherals.append(sensor)
//            }
//        }
    }
}

extension ScannerViewController: RecordingSessionDeviceDelegate {
    func didUpdateDevices() {
        DispatchQueue.main.async {
            self.sensorsTable.reloadData()
        }
    }
}

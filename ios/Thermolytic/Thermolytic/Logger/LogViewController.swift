//
//  LoggerViewController.swift
//  nRF Toolbox
//
//  Created by Mostafa Berg on 11/05/16.
//  Copyright © 2016 Nordic Semiconductor. All rights reserved.
//

import UIKit
import CoreBluetooth
import CouchbaseLiteSwift

class LogViewController: UIViewController {
    //MARK: - Properties
    var bluetoothManager : BluetoothManager?
    var logItems: [Result] = [] {
        didSet {
            self.displayLogTextTable.reloadData()
        }
    }
    
    //MARK: - View Outlets
    @IBOutlet weak var displayLogTextTable : UITableView!
    @IBOutlet weak var commandTextField : UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayLogTextTable.delegate = self
        displayLogTextTable.dataSource = self
        displayLogTextTable.rowHeight = UITableView.automaticDimension
        displayLogTextTable.estimatedRowHeight = 25
        
        commandTextField.placeholder = "No UART connected"
        commandTextField.delegate = self
        
        setDataSource()
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        // The 'scan' seque will be performed only if bluetoothManager == nil (if we are not connected already).
        return identifier != "connect" || bluetoothManager == nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "connect" else {
            return
        }
        
        // Set this contoller as scanner delegate
        let nc = segue.destination as! UINavigationController
        let controller = nc.children.first as! ScannerViewController
         controller.filterUUID = CBUUID.init(string: ServiceIdentifiers.uartServiceUUIDString)
        controller.delegate = self
    }
}

extension LogViewController {
    
    func setDataSource() {
        let query = QueryBuilder
            .select(BleMessage.createdAt.selectResult,
                    BleMessage.messageType.selectResult,
                    BleMessage.message.selectResult)
            .from(DataSource.database(DatabaseUtil.shared))
            .where(BaseDocument.type.expression.equalTo(Expression.string(BleMessage.TYPE)))
            .orderBy(Ordering.expression(BleMessage.createdAt.expression))
        
        query.addChangeListener({change in
            if let error = change.error {
                Utils.log(at: .Error, msg: "Error fetching data -- \(error)")
            }
            if let res = change.results {
                self.logItems = res.allResults()
            }
        })
    }
    
}

extension LogViewController: UITextFieldDelegate {
    
    func updateTextField() {
       if self.bluetoothManager != nil {
           commandTextField.placeholder = "Write command"
           commandTextField.text = ""
       } else {
           commandTextField.placeholder = "No UART service connected"
           commandTextField.text = ""
       }
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // Only shows the keyboard when a UART peripheral is connected
        return bluetoothManager != nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        commandTextField.resignFirstResponder()
        bluetoothManager?.send(text: self.commandTextField.text!)
        commandTextField.text = ""
        return true
    }
}

extension LogViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "logCell") as! LogItemTableViewCell
        let item = logItems[indexPath.row]
        cell.setItem(for: item)
        return cell
    }
}

// MARK: - Scanner Delegate
extension LogViewController: ScannerDelegate {
    func centralManagerDidSelectPeripheral(withManager aManager: CBCentralManager, andPeripheral aPeripheral: CBPeripheral) {
           // We may not use more than one Central Manager instance. Let's just take the one returned from Scanner View Controller
           bluetoothManager = BluetoothManager(withManager: aManager)
           bluetoothManager!.delegate = self
           bluetoothManager!.connectPeripheral(peripheral: aPeripheral)
           updateTextField()
       }
}

// MARK: - BluetoothManagerDelegate
extension LogViewController: BluetoothManagerDelegate {
       //MARK: - BluetoothManagerDelegate
       func peripheralReady() {  }
       
       func peripheralNotSupported() { }
       
       func didConnectPeripheral(deviceName aName: String?) {
           // Scanner uses other queue to send events. We must edit UI in the main queue
        DispatchQueue.main.async {
           
               //Following if condition display user permission alert for background notification
               if UIApplication.instancesRespond(to: #selector(UIApplication.registerUserNotificationSettings(_:))){
                   UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .alert], categories: nil))
               }

               NotificationCenter.default.addObserver(self, selector: #selector(self.applicationDidEnterBackgroundCallback), name: UIApplication.didEnterBackgroundNotification, object: nil)
               NotificationCenter.default.addObserver(self, selector: #selector(self.applicationDidBecomeActiveCallback), name: UIApplication.didBecomeActiveNotification, object: nil)
           }
       }

       func didDisconnectPeripheral() {
           // Scanner uses other queue to send events. We must edit UI in the main queue
           DispatchQueue.main.async {
               self.bluetoothManager = nil

               NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
               NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
           }
           bluetoothManager = nil
       }
    
    func didReceive(message: String) {
        let doc = BleMessage.create(type: .Received, message: message)
        addToDatabase(document: doc)
    }
    
    func didSend(message: String) {
        let doc = BleMessage.create(type: .Sent, message: message)
        addToDatabase(document: doc)
    }
    
    func addToDatabase(document: MutableDocument) {
        do {
            try DatabaseUtil.shared.saveDocument(document)
        } catch {
            Utils.log(at: .Error, msg: "Didnt add doc \(error)")
        }
    }

    @objc func applicationDidEnterBackgroundCallback(){
    }
    
    @objc func applicationDidBecomeActiveCallback(){
        UIApplication.shared.cancelAllLocalNotifications()
    }
    
}

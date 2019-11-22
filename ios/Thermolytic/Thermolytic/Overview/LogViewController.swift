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
import UserNotifications

class LogViewController: UIViewController {
    //MARK: - Properties
    var bluetoothManager : BluetoothManager?
    var userIds: [Int: Int] = [:]
    var logItems: [Int: Result] = [:] {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    //MARK: - View Outlets
    @IBOutlet weak var deviceLabel : UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var commandTextField : UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        commandTextField.placeholder = "No UART connected"
        commandTextField.delegate = self
        
        setDataSource()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let flowLayout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }
    }
    
    func setDataSource() {
        let query = QueryBuilder
            .select(
                BleMessage.uid.selectResult,
                SelectResult.expression(Function.max(BleMessage.createdAt.expression))
            )
            .from(DataSource.database(DatabaseUtil.shared))
            .where(BaseDocument.type.expression.equalTo(Expression.string(BleMessage.TYPE)))
            .groupBy(BleMessage.uid.expression)
            .orderBy(Ordering.expression(BleMessage.uid.expression))
        
        query.addChangeListener({change in
            if let error = change.error {
                Utils.log(at: .Error, msg: "Error fetching data -- \(error)")
            }
            if let res = change.results {
                for (index, user) in res.allResults().enumerated() {
                    do {
                        let uid = user.int(forKey: BleMessage.uid.key)
                        let userQuery = QueryBuilder
                            .select(
                                BleMessage.uid.selectResult,
                                BleMessage.createdAt.selectResult,
                                BleMessage.type.selectResult,
                                BleMessage.message.selectResult
                            )
                            .from(DataSource.database(DatabaseUtil.shared))
                            .where(
                                BaseDocument.type.expression.equalTo(Expression.string(BleMessage.TYPE))
                                .and(BleMessage.uid.expression.equalTo(Expression.int(uid)))
                        ).orderBy(Ordering.expression(BleMessage.createdAt.expression).descending())
                            .limit(Expression.int(1))
                        let record = try userQuery.execute()
                        self.logItems[uid] = record.allResults().first
                        self.userIds[index] = uid
                    } catch {
                        Utils.log(at: .Error, msg: "Error -- \(error)")
                    }
                }
            }
        })
    }
}

extension LogViewController {
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        let segues = ["connect", "detail"]
        return segues.contains(identifier)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "connect" {
            let vc = segue.destination as! ScannerViewController
            vc.filterUUID = CBUUID.init(string: ServiceIdentifiers.uartServiceUUIDString)
            vc.delegate = self
        } else if segue.identifier == "detail" {
            let vc = segue.destination as! DetailViewController
            let cell = sender as! LogItemCell
            vc.uid = cell.uid
        }
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


extension LogViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.logItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
          let padding: CGFloat =  50
          let collectionViewSize = collectionView.frame.size.width - padding

          return CGSize(width: collectionViewSize/2, height: collectionViewSize/2)
      }

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LogCell", for: indexPath) as! LogItemCell
        
        if let uid = userIds[indexPath.row], let item = logItems[uid] {
            cell.configure(for: item)
        }
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
        self.deviceLabel.text = aPeripheral.name
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
        
        let parts = message.components(separatedBy: ",")
        
        guard parts.count == 2, let uid = Int(parts[0]) else {
            Utils.log(at: .Error, msg: "Bad transmission, Not opening")
            return
        }
        
        let doc = BleMessage.create(type: .Received, message: parts[1],  uid: uid)
        addToDatabase(document: doc)
    }
    
    func didSend(message: String) {
        let doc = BleMessage.create(type: .Sent, message: message, uid: -50)
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
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
}

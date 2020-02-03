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
    var users: [Int: String] = [:]
    
    var logItems: [String: Result] = [:] {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    //MARK: - View Outlets
    @IBOutlet weak var deviceLabel : UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Dashboard"
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
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
                BioFrame.uid.selectResult,
                SelectResult.expression(Function.max(BioFrame.createdAt.expression))
            )
            .from(DataSource.database(DatabaseUtil.shared))
            .where(BaseDocument.type.expression.equalTo(Expression.string(BioFrame.TYPE)))
            .groupBy(BioFrame.uid.expression)
            .orderBy(Ordering.expression(BioFrame.uid.expression))
        
        query.addChangeListener({change in
            if let error = change.error {
                Utils.log(at: .Error, msg: "Error fetching data -- \(error)")
            }
            if let res = change.results {
                for (index, user) in res.allResults().enumerated() {
                    do {
                        if let uid = user.string(forKey: BioFrame.uid.key) {
                            let frameAlias = "frame"
                            let userAlias = "user"
                            let userQuery = QueryBuilder
                                .select(
                                    BioFrame.uid.selectResult(from: frameAlias),
                                    BioFrame.createdAt.selectResult(from: frameAlias),
                                    BioFrame.heartRate.selectResult(from: frameAlias),
                                    BioFrame.skinTemp.selectResult(from: frameAlias),
                                    BioFrame.predictedCoreTemp.selectResult(from: frameAlias),
                                    Athlete.name.selectResult(from: userAlias),
                                    Athlete.number.selectResult(from: userAlias)
                                )
                                .from(DataSource.database(DatabaseUtil.shared).as(frameAlias))
                                .join(
                                    Join.join(DataSource.database(DatabaseUtil.shared).as(userAlias))
                                        .on(
                                            BioFrame.uid.expression(from: frameAlias)
                                                .equalTo(Athlete.id.expression(from: userAlias))
                                    )
                                )
                                .where(
                                BaseDocument.type.expression(from: frameAlias).equalTo(Expression.string(BioFrame.TYPE))
                                    .and(BaseDocument.type.expression(from: userAlias).equalTo(Expression.string(Athlete.TYPE)))
                                    .and(BioFrame.uid.expression(from: frameAlias).equalTo(Expression.string(uid)))
                            ).orderBy(Ordering.expression(BioFrame.createdAt.expression(from: frameAlias)).descending())
                                .limit(Expression.int(1))
                            let record = try userQuery.execute()
                            self.logItems[uid] = record.allResults().first
                            self.users[index] = uid
                        }
                    } catch {
                        Utils.log(at: .Error, msg: "\(error)")
                    }
                }
            }
        })
    }
}

extension LogViewController {
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        let segues = ["connect", "detail", "addPlayer"]
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
            vc.uid = cell.uid!
        }
    }
}

extension LogViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.logItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "overview_cell", for: indexPath) as! LogItemCell
        
        if let user = users[indexPath.row], let item = logItems[user] {
            cell.configure(item: item)
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
        
        guard parts.count == 5 else {
            Utils.log(at: .Error, msg: "Bad transmission, Not opening")
            return
        }
        guard let _ = Double(parts[4]), let _ = Double(parts[3]) else {
            return
        }
        let coreTemp = TwoNode.getCoreTemp(mass_body: 81,
                                           temp_skin_avg: Double(parts[2])!,
                                           heart_rate_rest: 60,
                                           heart_rate: 100, // Double(parts[1])!,
                                           rel_humidity: Double(parts[4])! / 100.0,
                                           temp_air: Double(parts[3])!)

        if let doc = BioFrame.createFromMessage(uid: parts[0], heartRate: parts[1], skinTemp: parts[2], ambientTemp: parts[3], ambientHumidity: parts[4], predictedCoreTemp: coreTemp) {
            addToDatabase(document: doc)
        } else {
            Utils.log(at: .Warning, msg: "Could not create frame for \(message)")
        }
    }
    
    func didSend(message: String) {
//        let doc = BleMessage.create(type: .Sent, message: message, uid: -50)
//        addToDatabase(document: doc)
    }
    
    func addToDatabase(document: MutableDocument) {
        DatabaseUtil.insert(doc: document)
    }

    @objc func applicationDidEnterBackgroundCallback(){
    }
    
    @objc func applicationDidBecomeActiveCallback(){
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
}

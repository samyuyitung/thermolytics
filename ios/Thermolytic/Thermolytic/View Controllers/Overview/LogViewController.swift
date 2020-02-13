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
//    var bluetoothManager : BluetoothManager?
    var sessionManager = RecordingSessionManager.shared
//    var hrManager : PolarHrUtil = PolarHrUtil()
    var users: [Int: String] = [:]
    var devices: [String: String] = ["1": "--DL2Z5ZBvoStzHDd6tQAhR"]
    
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
                                    BioFrame.avgSkinTemp.selectResult(from: frameAlias),
                                    BioFrame.predictedCoreTemp.selectResult(from: frameAlias),
                                    Athlete.id.selectResult(from: userAlias),
                                    Athlete.name.selectResult(from: userAlias),
                                    Athlete.number.selectResult(from: userAlias),
                                    Athlete.weight.selectResult(from: userAlias)
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

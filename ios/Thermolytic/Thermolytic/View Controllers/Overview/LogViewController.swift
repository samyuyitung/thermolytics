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
    var sessionManager = RecordingSessionManager.shared
    var users: [Int: String] = [:]
    
    var logItems: [String: Result] = [:] {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    var query: Query? = nil
    var token: ListenerToken? = nil
    //MARK: - View Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Dashboard"
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        configureRecordButton()
        sessionManager.delegate = self
    }
    
    
    func configureRecordButton() {
        let button = UIButton()
        button.frame = CGRect(x:0.0, y:0.0, width: 150, height: 30.0)
        button.addTarget(self, action: #selector(didPressRecord), for: .touchUpInside)
        button.setImage(UIImage(named: "record"), for: .normal)
        button.setImage(UIImage(named: "record"), for: .selected)
        button.imageView?.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .left;
        button.imageEdgeInsets = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
        button.setTitle("Record", for: .normal)
        button.setTitle("Recording", for: .selected)
        button.setTitleColor(.black, for: .normal)
        
        let barButton = UIBarButtonItem(customView: button)
        navigationItem.leftBarButtonItem = barButton
    }
    
    @objc func didPressRecord(_ sender: Any?) {
        guard sessionManager.participants.count > 0 else{
            return
        }
        
        let button = navigationItem.leftBarButtonItem?.customView as! UIButton
        if !button.isSelected {
            performSegue(withIdentifier: "startSession", sender: nil)
        } else {
            sessionManager.stopSession()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let flowLayout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }
    }
    
    func setDataSource() {
        query = QueryBuilder
            .select(
                BioFrame.uid.selectResult,
                SelectResult.expression(Function.max(BioFrame.createdAt.expression))
        )
            .from(DataSource.database(DatabaseUtil.shared))
            .where(BaseDocument.type.expression.equalTo(Expression.string(BioFrame.TYPE))
                .and(BioFrame.uid.expression.in(Array(sessionManager.participants.keys).map({ it -> ExpressionProtocol in
                    return Expression.string(it)
                }))))
            .groupBy(BioFrame.uid.expression)
            .orderBy(Ordering.expression(BioFrame.uid.expression))
        token = query?.simpleListener({ res in
            for (index, user) in res.enumerated() {
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
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }
    
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

extension LogViewController: RecordingSessionDelegate {
    func didStartSession(named: String) {
        setDataSource()
        setButtonState(to: true)
    }
    
    func didStopSession() {
        if let token = token {
            query?.removeChangeListener(withToken: token)
        }
        
        setButtonState(to: false)

    }
    
    func setButtonState(to state: Bool) {
        let button = navigationItem.leftBarButtonItem?.customView as! UIButton
        button.isSelected = state
    }
}

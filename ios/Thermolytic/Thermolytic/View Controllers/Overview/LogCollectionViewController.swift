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

class LogCollectionViewController: UICollectionViewController {
    
    enum Section: Int {
        case active = 0
        case bench = 1
    }
    
    //MARK: - Properties
    var sessionManager = RecordingSessionManager.shared
    var users: [String: Result] = [:] {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    var logItems: [String: Result] = [:] {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    var queries: [Query]? = nil
    var tokens: [ListenerToken]? = nil
    var userQuery: Query? = nil
    var userTokens: ListenerToken? = nil
    
    let headerIdentifier = "header"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Dashboard"
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        collectionView.register(UINib(nibName: "LogCollectionViewHeader", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier:headerIdentifier)
        configureRecordButton()
        sessionManager.delegate = self
        
        setDataSource()
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
//
//        if let flowLayout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
//            flowLayout.estimatedItemSize = CGSize(width: 1, height: 1)
//        }
    }
    
    
    func setDataSource() {
        let allPlayers = Array(sessionManager.participants.keys)
        getUsers(with: allPlayers)
        getData(for: allPlayers)
    }
    
    func getUsers(with uids: [String]) {
        let query = QueryBuilder
            .select(Athlete.selectAll)
            .from(DataSource.database(DatabaseUtil.shared))
            .where(BaseDocument.type.expression.equalTo(Athlete.type.expression)
                .and(Athlete.id.expression.in(uids.map { it in Expression.string(it)})))
        
        let _ = query.simpleListener { res in
            for row in res {
                if let uid = row.getId() {
                    self.users[uid] = row
                }
            }
        }
    }
    
    func getData(for uids: [String]) {
        guard sessionManager.isRecording else {
            return
        }
        
        queries = uids.map { uid in
            QueryBuilder
                .select(BioFrame.selectAll)
                .from(DataSource.database(DatabaseUtil.shared))
                .where(BaseDocument.type.expression.equalTo(Expression.string(BioFrame.TYPE))
                    .and(BioFrame.uid.expression.equalTo(Expression.string(uid))))
                .orderBy(Ordering.expression(BioFrame.createdAt.expression).descending())
                .limit(Expression.int(1))
        }
        
        tokens = queries?.map { it in
            return it.simpleListener { res in
                if let row = res.first, let uid = row.string(forKey: BioFrame.uid.key) {
                    self.logItems[uid] = row
                }
            }
        }
    }
}

extension LogCollectionViewController {
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

extension LogCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 300, height: 300) // Return any non-zero size here
    }
}
extension LogCollectionViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let section = Section(rawValue: section)
        switch section {
        case .active: return sessionManager.activePlayers.count
        case .bench: return sessionManager.benchPlayers.count
        default: return 0
        }
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "overview_cell", for: indexPath) as! LogItemCell
        let section = Section(rawValue: indexPath.section)
        
        var uid: String? = nil
        switch section {
        case .active:
            uid = sessionManager.activePlayers[indexPath.row]
        case .bench:
            uid = sessionManager.benchPlayers[indexPath.row]
        default:
            uid = nil
        }
        
        if let uid = uid, let user = users[uid] {
            let item = logItems[uid]
            cell.configure(user: user, frame: item)
        }
        return cell
    }
    
     override func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {

        switch kind {

        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! LogCollectionViewHeader
            let section = Section(rawValue: indexPath.section)

            headerView.title.text = section == .active ? "Active" : "Bench"

            return headerView

        default:
            assert(false, "Unexpected element kind")
        }
    }

}

extension LogCollectionViewController: RecordingSessionDelegate {
    func didUpdateParticipants() {
       setDataSource()
    }
    
    
    func didStartSession(named: String) {
        setButtonState(to: true)
    }
    
    func didStopSession() {
        if let queries = queries {
            for (i, query) in queries.enumerated() {
                if let token = tokens?[i] {
                    query.removeChangeListener(withToken: token)
                }
            }
        }
        setButtonState(to: false)

    }
    
    func setButtonState(to state: Bool) {
        let button = navigationItem.leftBarButtonItem?.customView as! UIButton
        button.isSelected = state
    }
}

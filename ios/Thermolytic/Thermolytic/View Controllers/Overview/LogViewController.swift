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
    var users: [String: Result] = [:] {
        didSet {
            reloadViews()
        }
    }
    
    var logItems: [String: Result] = [:] {
        didSet {
            reloadViews()
        }
    }
    
    private func reloadViews() {
        for view in [activeCollectionView!, benchCollectionView!] {
            view.reloadData()
            view.collectionViewLayout.invalidateLayout()
            view.layoutIfNeeded()
        }
        let height = activeCollectionView.collectionViewLayout.collectionViewContentSize.height
        activeViewControllerHeight.constant = height + 20

    }
    
    var queries: [Query]? = nil
    var tokens: [ListenerToken]? = nil
    var userQuery: Query? = nil
    var userTokens: ListenerToken? = nil

    
    @IBOutlet weak var activeCollectionView: UICollectionView!
    @IBOutlet weak var benchCollectionView: UICollectionView!
    @IBOutlet weak var activeViewControllerHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Dashboard"
        
        setup(view: activeCollectionView)
        setup(view: benchCollectionView)

        configureRecordButton()
        configureConnectionButton()
        sessionManager.delegate = self
        
        setDataSource()
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        reloadViews()
    }
    
    private func setup(view: UICollectionView) {
        view.delegate = self
        view.dataSource = self
        view.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        view.collectionViewLayout = LeftAlignedCollectionViewFlowLayout()
    }
    
    func configureRecordButton() {
        let button = UIButton()
        button.frame = CGRect(x:0.0, y:0.0, width: 150, height: 30.0)
        button.addTarget(self, action: #selector(didPressRecord), for: .touchUpInside)
        button.setImage(UIImage(named: "record"), for: .normal)
        button.setImage(UIImage(named: "record"), for: .selected)
        button.imageView?.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .left;
        button.imageEdgeInsets = UIEdgeInsets(top: 9, left: 0, bottom: 9, right: 0)
        button.setTitle("Record", for: .normal)
        button.setTitle("Recording", for: .selected)
        button.setTitleColor(.black, for: .normal)
        
        let barButton = UIBarButtonItem(customView: button)
        navigationItem.leftBarButtonItem = barButton
    }
    
    func configureConnectionButton() {
          let button = UIButton()
          button.frame = CGRect(x:0.0, y:0.0, width: 120, height: 30.0)
          button.addTarget(self, action: #selector(didPressConnection), for: .touchUpInside)
          button.setImage(UIImage(named: "connection"), for: .normal)
          button.imageView?.contentMode = .scaleAspectFit
          button.contentHorizontalAlignment = .left;
          button.imageEdgeInsets = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
          button.setTitle("Connection", for: .normal)
          button.setTitleColor(.black, for: .normal)
          
          let barButton = UIBarButtonItem(customView: button)
          navigationItem.rightBarButtonItem = barButton
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
    
    @objc func didPressConnection(_ sender: Any?) {
        performSegue(withIdentifier: "connection", sender: nil)
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
                    .and(BioFrame.uid.expression.equalTo(Expression.string(uid)))
                    .and(BioFrame.session.expression.equalTo(Expression.string(sessionManager.sessionName))))
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

extension LogViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private func getWidthForOrientation(frame: CGRect, isLandscape: Bool) -> Double {
        if isLandscape {
            return Double(frame.width - 50) / LogItemCell.landscapeWidthRatio
        } else {
            return Double(frame.width - 30) / LogItemCell.portraitWidthRatio
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let frame = collectionView.frame
        var width = 0.0
        
        switch UIDevice.current.orientation {
        case .landscapeLeft, .landscapeRight:
            width = getWidthForOrientation(frame: frame, isLandscape: true)
        case .portraitUpsideDown, .portrait:
            width = getWidthForOrientation(frame: frame, isLandscape: false)
        case .faceUp:
            let statusBarOrientation = UIApplication.shared.statusBarOrientation
            let isLandscape = statusBarOrientation == .landscapeRight || statusBarOrientation == .landscapeLeft
            width = getWidthForOrientation(frame: frame, isLandscape: isLandscape)
        default: width = 0
        }

        return CGSize(width: CGFloat(width), height: CGFloat(LogItemCell.height))
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch collectionView {
        case activeCollectionView: return sessionManager.activePlayers.count
        case benchCollectionView: return sessionManager.benchPlayers.count
        default: return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "overview_cell", for: indexPath) as! LogItemCell
        
        var uid: String? = nil
        switch collectionView {
        case activeCollectionView:
            uid = sessionManager.activePlayers[indexPath.row]
        case benchCollectionView:
            uid = sessionManager.benchPlayers[indexPath.row]
        default:
            uid = nil
        }
        
        if let uid = uid, let user = users[uid] {
            let item = logItems[uid]
            cell.configure(user: user, frame: item, onBench: collectionView == benchCollectionView)
            cell.delegate = self
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! LogItemCell
        guard let uid = cell.uid else {
            return
        }

        if collectionView == activeCollectionView,
            let _ = sessionManager.activePlayers.drop(where: { id in uid == id }) {
            sessionManager.benchPlayers.append(uid)
            reloadViews()
        } else if collectionView == benchCollectionView {
            guard sessionManager.activePlayers.count < 4 else {
                return // Can only have 4 on the court
            }
            if let _ = sessionManager.benchPlayers.drop(where: { id in uid == id }) {
                sessionManager.activePlayers.append(uid)
                reloadViews()
            }
        }
    }
}

extension LogViewController: LogItemCellDelegate {
    func didPressDetail(for cell: LogItemCell) {
        performSegue(withIdentifier: "detail", sender: cell)
    }
}

extension LogViewController: RecordingSessionDelegate {
    func didUpdateParticipants() {
       setDataSource()
    }
    
    
    func didStartSession(named: String) {
        setDataSource()
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


extension Array {
    mutating func drop(where predicate: (Element) -> Bool ) -> Element? {
        if let index = self.firstIndex(where: predicate) {
            return self.remove(at: index)
        }
        return nil
    }
}


class LeftAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)

        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0
        attributes?.forEach { layoutAttribute in
            if layoutAttribute.frame.origin.y >= maxY {
                leftMargin = sectionInset.left
            }

            layoutAttribute.frame.origin.x = leftMargin

            leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
            maxY = max(layoutAttribute.frame.maxY , maxY)
        }

        return attributes
    }
}

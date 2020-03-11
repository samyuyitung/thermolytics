//
//  SelectPlayerViewController.swift
//  Thermolytic
//
//  Created by Sam Yuyitung on 2020-02-23.
//  Copyright © 2020 Sam Yuyitung. All rights reserved.
//

import UIKit
import CouchbaseLiteSwift


class SelectPlayerViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UIView!
    
    @IBAction func didPressBackground(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    var athletes: [Result] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var deviceId: String? = nil
    
    override func viewDidLoad() {
        tableView.dataSource = self
        tableView.delegate = self
        
        assert(deviceId != nil)
        
        setQuery()
    }
    
    func setQuery() {
        let query = QueryBuilder
            .select(Athlete.selectAll)
            .from(DataSource.database(DatabaseUtil.shared))
            .where(BaseDocument.type.expression.equalTo(Expression.string(Athlete.TYPE)))
            .orderBy(Ordering.expression(Athlete.number.expression).ascending())
        
        query.simpleListener { (results) in
            let alreadySelected = Array(RecordingSessionManager.shared.participants.keys)
            
            self.athletes = results.filter { doc -> Bool in
                guard let id = doc.getId() else {
                    return false
                }
                return !alreadySelected.contains(id)
            }
        }

    }
}

extension SelectPlayerViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return athletes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SelectPlayerCell
        cell.configure(for: athletes[indexPath.row])
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let athlete = athletes[indexPath.row]
        if RecordingSessionManager.shared.addParticipant(uid: athlete.getId()!, deviceId: deviceId!) {
            self.dismiss(animated: true)
        }
        
    }
    
    
}

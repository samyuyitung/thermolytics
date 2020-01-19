//
//  DetailViewController.swift
//  Thermolytic
//
//  Created by Sam Yuyitung on 2019-11-20.
//  Copyright © 2019 Sam Yuyitung. All rights reserved.
//

import Foundation
import UIKit
import CouchbaseLiteSwift

class DetailViewController: UIViewController {
    @IBOutlet weak var topTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var uid: Int = -10
    var logItems: [Result] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        setQuery()
    }
    
    func setQuery() {
        let dataQuery = QueryBuilder
            .select(BioFrame.selectAll)
            .from(DataSource.database(DatabaseUtil.shared))
            .where(
                BaseDocument.type.expression.equalTo(Expression.string(BioFrame.TYPE))
                    .and(BioFrame.uid.expression.equalTo(Expression.int(uid)))
        ).orderBy(Ordering.expression(BioFrame.createdAt.expression).descending())
        dataQuery.addChangeListener({change in
            if let error = change.error {
                Utils.log(at: .Error, msg: "Error fetching data -- \(error)")
            }
            if let res = change.results {
                self.logItems = res.allResults()
            }
        })
        
        let userQuery = QueryBuilder
            .select(Athlete.selectAll)
            .from(DataSource.database(DatabaseUtil.shared))
            .where(
                BaseDocument.type.expression.equalTo(Expression.string(Athlete.TYPE))
                    .and(Athlete.uid.expression.equalTo(Expression.int(uid)))
        )
        userQuery.addChangeListener({change in
            if let error = change.error {
                Utils.log(at: .Error, msg: "Error fetching data -- \(error)")
            }
            if let res = change.results?.allResults().first {
                self.updateUserInfo(result: res)
            }
        })
    }
}

extension DetailViewController {
    func updateUserInfo(result: Result) {
        self.title = result.string(forKey: Athlete.name.key)
    }
}

extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Message") as! MessageTableViewCell
        let item = logItems[indexPath.row]
        cell.configure(for: item)
        return cell
    }
}

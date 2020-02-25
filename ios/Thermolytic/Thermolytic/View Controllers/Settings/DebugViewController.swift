//
//  DebugViewController.swift
//  Thermolytic
//
//  Created by Sam Yuyitung on 2019-11-30.
//  Copyright © 2019 Sam Yuyitung. All rights reserved.
//

import UIKit
import CouchbaseLiteSwift

class DebugViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func didClickDelete(_ sender: Any) {
        DatabaseUtil.clearAllOf(type: BioFrame.TYPE)
    }
    
    @IBAction func didAddRows(_ sender: Any) {
    }
    
    var rows: [Result] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        
        QueryBuilder
            .select(BioFrame.selectAll)
            .from(DataSource.database(DatabaseUtil.shared))
            .where(BaseDocument.type.expression.equalTo(Expression.string(BioFrame.TYPE)))
            .orderBy(Ordering.expression(BioFrame.createdAt.expression).descending())
            .limit(Expression.int(50))
            .simpleListener { res in
                self.rows = res
            }
    }
}

extension DebugViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BioFrameDebuggerCell") as! BioFrameDebuggerCell
        cell.configure(with: rows[indexPath.row])
        return cell
    }
}

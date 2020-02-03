//
//  ListPlayersViewController.swift
//  Thermolytic
//
//  Created by Sam Yuyitung on 2020-01-21.
//  Copyright © 2020 Sam Yuyitung. All rights reserved.
//

import UIKit
import CouchbaseLiteSwift

class ListPlayerViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var users: [Result] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        tableView.dataSource = self
        tableView.delegate = self
        
        self.title = "All Players"
        setQuery()
    }
    
    func setQuery() {
        
        let query = QueryBuilder
            .select(Athlete.selectAll)
            .from(DataSource.database(DatabaseUtil.shared))
            .where(BaseDocument.type.expression.equalTo(Expression.string(Athlete.TYPE)))
            .orderBy(Ordering.expression(Athlete.number.expression).ascending())
        
        query.simpleListener { (results) in
            self.users = results
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
         if segue.identifier == "detail" {
            let vc = segue.destination as! HistoricalDetailViewController
            let cell = sender as! PlayerTableViewCell
            vc.uid = cell.uid ?? ""
        }
    }
}

extension ListPlayerViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerTableViewCell") as! PlayerTableViewCell
        cell.configure(for: users[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "detail", sender: tableView.cellForRow(at: indexPath))
    }
}

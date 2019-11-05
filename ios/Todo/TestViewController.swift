//
//  TestViewController.swift
//  Todo
//
//  Created by Sam Yuyitung on 2019-11-05.
//  Copyright © 2019 Couchbase. All rights reserved.
//

import UIKit
import CouchbaseLiteSwift

class TestViewController: UITableViewController {
    
    
    var database: Database!
    var username: String!
    
    var listQuery: Query!
    var listRows : [Result]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get database:
        database = DatabaseUtil.shared
        
        // Get username:
        username = User.username
        
        load()
//        Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(TestViewController.putFrame), userInfo: nil, repeats: true)
        
    }

    @objc func putFrame() {
        do {
            let doc = BiometricsFrame.create(ts: Date().timeIntervalSince1970, heartRate: 91, skinTemp: 32.1, accelerometer: Accelerometer(x: 1,y: 2,z: 3))
            try DatabaseUtil.shared.saveDocument(doc)
        } catch {
            Utils.log(at: .Error, msg: "Didnt add doc \(error)")
        }
    }

    // MARK: - Database
    
    func load() {
        let dataQuery = QueryBuilder
            .select(BiometricsFrame.id.selectResult,
                    BiometricsFrame.heartRate.selectResult,
                    BiometricsFrame.skinTemp.selectResult,
                    BiometricsFrame.accelerometer.selectResult)
            .from(DataSource.database(database))
            .where(BaseDocument.type.expression.equalTo(Expression.string(BiometricsFrame.TYPE)))
            .orderBy(Ordering.expression(BiometricsFrame.createdAt.expression))
        dataQuery.addChangeListener({change in
            if let error = change.error {
                Utils.log(at: .Error, msg: "Error fetching data -- \(error)")
            }
            if let rows = change.results {
                self.listRows = rows.allResults()

            }
            self.tableView.reloadData()
        })
    }
   
    // MARK: - UITableViewController
    
    var data: [Result]? {
        return listRows
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskListCell", for: indexPath)
        let row = self.data![indexPath.row]
        cell.textLabel?.text = "\(row.double(at: 1))"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let row = self.data![indexPath.row]

        let delete = UITableViewRowAction(style: .normal, title: "Delete") {
            (action, indexPath) -> Void in
            // Dismiss row actions:
            tableView.setEditing(false, animated: true)
        }
        delete.backgroundColor = UIColor(red: 1.0, green: 0.23, blue: 0.19, alpha: 1.0)
        
        let update = UITableViewRowAction(style: .normal, title: "Edit") {
            (action, indexPath) -> Void in
            // Dismiss row actions:
            tableView.setEditing(false, animated: true)
        }
        update.backgroundColor = UIColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0)
        
        return [delete, update]
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let tabBarController = segue.destination as? UITabBarController {
            let row = self.data![self.tableView.indexPathForSelectedRow!.row]
            let docID = row.string(at: 0)!
            let taskList = database.document(withID: docID)!
            
            let tasksController = tabBarController.viewControllers![0] as! TasksViewController
            tasksController.taskList = taskList
        }
    }
}

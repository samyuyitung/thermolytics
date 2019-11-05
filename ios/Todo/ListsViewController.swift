//
//  TaskListsViewController.swift
//  Todo
//
//  Created by Pasin Suriyentrakorn on 2/8/16.
//  Copyright © 2016 Couchbase. All rights reserved.
//

import UIKit
import CouchbaseLiteSwift

class ListsViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {    
    var searchController: UISearchController!
    
    var database: Database!
    var username: String!
    
    var listQuery: Query!
    var listRows : [Result]?
    
    var searchQuery: Query!
    var inSearch = false;
    var searchRows : [Result]?
    
    var incompTasksCountsQuery: Query!
    var incompTasksCounts: [String:Int] = [:]
    var shouldUpdateIncompTasksCount = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup SearchController:
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        self.tableView.tableHeaderView = searchController.searchBar
        
        // Get database:
        database = DatabaseUtil.shared
        
        // Get username:
        username = User.username
        
        load()
    }
    
    // MARK: - Database
    
    func load() {
        if (listQuery == nil) {
            // Task List:
            listQuery = QueryBuilder
                .select(S_ID, S_NAME)
                .from(DataSource.database(database))
                .where(TYPE.equalTo(Expression.string("task-list")))
                .orderBy(Ordering.expression(NAME))
            
            listQuery.addChangeListener({ (change) in
                if let error = change.error {
                    NSLog("Error querying task list: %@", error.localizedDescription)
                }
                self.listRows = change.results != nil ? Array(change.results!) : nil
                self.tableView.reloadData()
            })
            
            // Incomplete tasks count:
            incompTasksCountsQuery = QueryBuilder
                .select(S_TASK_LIST_ID, S_COUNT)
                .from(DataSource.database(database))
                .where(TYPE.equalTo(Expression.string("task")).and(COMPLETE.equalTo(Expression.boolean(false))))
                .groupBy(TASK_LIST_ID)
            
            incompTasksCountsQuery.addChangeListener({ (change) in
                if change.error == nil {
                    self.updateIncompleteTasksCounts(change.results!)
                } else {
                    NSLog("Error querying task list: %@", change.error!.localizedDescription)
                }
            })
        }
    }
    
    func updateIncompleteTasksCounts(_ rows: ResultSet) {
        incompTasksCounts.removeAll()
        for row in rows {
            incompTasksCounts[row.string(at: 0)!] = row.int(at: 1)
        }
        tableView.reloadData()
    }
    
    func createTaskList(name: String) {
        let docId = username + "." + NSUUID().uuidString
        let doc = MutableDocument(id: docId)
        doc.setValue("task-list", forKey: "type")
        doc.setValue(name, forKey: "name")
        doc.setValue(username, forKey: "owner")
        
        do {
            try database.saveDocument(doc)
        } catch let error as NSError {
            Ui.showError(on: self, message: "Couldn't save task list", error: error)
        }
    }
    
    func updateTaskList(listID: String, withName name: String) {
        let list = database.document(withID: listID)!.toMutable()
        list.setValue(name, forKey: "name")
        do {
            try database.saveDocument(list)
        } catch let error as NSError {
            Ui.showError(on: self, message: "Couldn't update task list", error: error)
        }
    }
    
    func deleteTaskList(listID: String) {
        do {
            let list = database.document(withID: listID)!
            try database.deleteDocument(list)
        } catch let error as NSError {
            Ui.showError(on: self, message: "Couldn't delete task list", error: error)
        }
    }
    
    func searchTaskList(name: String) {
        searchQuery = QueryBuilder.select(S_ID, S_NAME)
            .from(DataSource.database(database))
            .where(TYPE.equalTo(Expression.string("task-list")).and(NAME.like(Expression.string("%\(name)%"))))
            .orderBy(Ordering.expression(NAME))
        
        do {
            let rows = try searchQuery.execute()
            searchRows = Array(rows)
            tableView.reloadData()
        } catch let error as NSError {
            NSLog("Error searching task list: %@", error)
        }
    }
    
    // MARK: - Action
    
    @IBAction func addAction(sender: AnyObject) {
        Ui.showTextInput(on: self, title: "New Task List", message:  nil, textFieldConfig: { text in
            text.placeholder = "List name"
            text.autocapitalizationType = .words
        }, onOk: { name in
            self.createTaskList(name: name)
        })
    }
   
    // MARK: - UITableViewController
    
    var data: [Result]? {
        return inSearch ? searchRows : listRows
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskListCell", for: indexPath)
        let row = self.data![indexPath.row]
        cell.textLabel?.text = row.string(at: 1)
        cell.detailTextLabel?.text = nil
        
        let docID = row.string(at: 0)!
        let count = incompTasksCounts[docID] ?? 0
        cell.detailTextLabel?.text = count > 0 ? "\(count)" : ""
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let row = self.data![indexPath.row]
        let docID = row.string(at: 0)!
        
        let delete = UITableViewRowAction(style: .normal, title: "Delete") {
            (action, indexPath) -> Void in
            // Dismiss row actions:
            tableView.setEditing(false, animated: true)
            
            // Delete list document:
            self.deleteTaskList(listID: docID)
        }
        delete.backgroundColor = UIColor(red: 1.0, green: 0.23, blue: 0.19, alpha: 1.0)
        
        let update = UITableViewRowAction(style: .normal, title: "Edit") {
            (action, indexPath) -> Void in
            // Dismiss row actions:
            tableView.setEditing(false, animated: true)
            
            // Display update list dialog:
            Ui.showTextInput(on: self, title: "Edit List", message:  nil, textFieldConfig: { text in
                let doc = self.database.document(withID: docID)!
                text.placeholder = "List name"
                text.text = doc.string(forKey: "name")
                text.autocapitalizationType = .words
            }, onOk: { (name) -> Void in
                self.updateTaskList(listID: docID, withName: name)
            })
        }
        update.backgroundColor = UIColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0)
        
        return [delete, update]
    }
    
    // MARK: - UISearchController
    
    func updateSearchResults(for searchController: UISearchController) {
        if let name = searchController.searchBar.text, !name.isEmpty {
            inSearch = true
            searchTaskList(name: name)
        } else {
            searchBarCancelButtonClicked(searchController.searchBar)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        inSearch = false
        searchRows = nil
        self.tableView.reloadData()
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

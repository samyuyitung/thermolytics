//
//  ListPlayersViewController.swift
//  Thermolytic
//
//  Created by Sam Yuyitung on 2020-01-21.
//  Copyright © 2020 Sam Yuyitung. All rights reserved.
//

import UIKit
import CouchbaseLiteSwift

class ListPlayerViewController: TLViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchbar: UISearchBar!

    @IBOutlet weak var addPlayerButton: UIButton!
    
    var users: [Result] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var filteredUsers: [Result] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    func isSearching() -> Bool {
        return self.searchbar.text?.isEmpty == false
    }
    
    override func viewDidLoad() {
        permissions.append(
            Permissioned(view: self.addPlayerButton, effect: .hide, minLevel: .physiologist)
        )
        
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        configureSearchBar()
        self.title = "All Players"
        
        setQuery()
    }
    
    func configureSearchBar() {
        searchbar.barTintColor = .white
        searchbar.backgroundColor = .white
        searchbar.layer.cornerRadius = 15;
        searchbar.layer.borderWidth = 1.0;
        searchbar.layer.masksToBounds = true;
        
        searchbar.delegate = self
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
        if isSearching() {
            return filteredUsers.count
        } else {
            return users.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerTableViewCell") as! PlayerTableViewCell
        
        if isSearching() {
            cell.configure(for: filteredUsers[indexPath.row])
        } else {
            cell.configure(for: users[indexPath.row])
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "detail", sender: tableView.cellForRow(at: indexPath))
    }
}

extension ListPlayerViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterRows()
    }
    
    
    func filterRows() {
        filteredUsers = users.filter { (row) -> Bool in
            let names = row.string(forKey: Athlete.name.key)?.lowercased().split(separator: " ")
            let text = self.searchbar.text?.lowercased().split(separator: " ")
            
            if var names = names, let text = text {
                for term in text {
                    if let i = names.firstIndex(where: { name -> Bool in
                        name.starts(with: term)
                    }) {
                        names.remove(at: i)
                    } else {
                        return false
                    }
                }
                return true
            }
            return false
        }
    }
}

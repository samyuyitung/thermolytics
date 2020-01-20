//
//  DebugViewController.swift
//  Thermolytic
//
//  Created by Sam Yuyitung on 2019-11-30.
//  Copyright © 2019 Sam Yuyitung. All rights reserved.
//

import Foundation
import UIKit
import CouchbaseLiteSwift

class DebugViewController: UIViewController {

    @IBOutlet weak var dbSize: UILabel!
    
    @IBAction func didClickDelete(_ sender: Any) {
        DatabaseUtil.clearAllOf(type: BioFrame.TYPE)
    }
    
    @IBAction func didAddRows(_ sender: Any) {
        let a = Athlete.create(uid: 1, name: "Justin Schaper", height: 180, weight: 60)
        let h = Athlete.create(uid: 2, name: "Heather Chan", height: 180, weight: 60)
       DatabaseUtil.insert(doc: a)
        DatabaseUtil.insert(doc: h)
        
    }
    override func viewDidLoad() {
//        let query = QueryBuilder.select(BioFrame.uid.selectResult) .from(DataSource.database(DatabaseUtil.shared))
//            .where(BaseDocument.type.expression.equalTo(Expression.string(BioFrame.TYPE)))
//
//        query.addChangeListener { (change) in
//            self.dbSize.text = "Num rows: \(change.results?.allResults().count)"
//        }
    }
}
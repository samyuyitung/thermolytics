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
        let max = 50000
        for _ in 1...max {
            if let doc = BioFrame.create(uid: 1000, heartRate: 120, skinTemp: 33.2, ambientTemp: 33.2, ambientHumidity: 33.2, predictedCoreTemp: 33.2) {
                DatabaseUtil.insert(doc: doc)
            }
            
        }
        

        let query = QueryBuilder.select(BioFrame.id.selectResult)
            .from(DataSource.database(DatabaseUtil.shared))
            .where(BaseDocument.type.expression.equalTo(Expression.string(BioFrame.TYPE)))
        
        do {
            let results = try query.execute()
            self.dbSize.text = "Num rows: \(results.allResults().count)"
        } catch {}
        
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

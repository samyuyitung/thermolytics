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
    
    @IBOutlet weak var dbSize: UILabel!
    
    @IBAction func didClickDelete(_ sender: Any) {
        DatabaseUtil.clearAllOf(type: BioFrame.TYPE)
    }
    
    @IBAction func didAddRows(_ sender: Any) {
        let baseTime = Date().timeIntervalSince1970
        for i in 1...500 {
            let doc = BioFrame.create(now: baseTime.advanced(by: Double(i) * 5.0), uid: "-4sNeT_RRDhPOvoFwJ4q_7U", heartRate: Int.random(in: 80...100), skinTemp: Double.random(in: 35.5...37.5), ambientTemp: 20.2, ambientHumidity: 0.2, predictedCoreTemp: Double.random(in: 37.6...39.4))!
            
            DatabaseUtil.insert(doc: doc)
            
        }
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

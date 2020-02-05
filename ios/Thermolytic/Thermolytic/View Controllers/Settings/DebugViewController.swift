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
        
            let doc = BioFrame.create(now: baseTime, uid: "--DL2Z5ZBvoStzHDd6tQAhR", heartRate: 100, skinTemp: 35, ambientTemp: 20.2, ambientHumidity: 0.2, predictedCoreTemp: 36)!
            
            DatabaseUtil.insert(doc: doc)
            
    }
}

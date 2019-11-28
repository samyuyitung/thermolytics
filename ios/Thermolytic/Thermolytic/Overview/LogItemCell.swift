//
//  LogItemCell.swift
//  Thermolytic
//
//  Created by Sam Yuyitung on 2019-11-20.
//  Copyright © 2019 Sam Yuyitung. All rights reserved.
//


import UIKit
import CouchbaseLiteSwift

class LogItemCell: UICollectionViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var number: UILabel!
    @IBOutlet weak var heartRate: UILabel!
    @IBOutlet weak var temperature: UILabel!
    
    var uid: Int = -1
    
    func configure(for item: Result) {
        uid = item.int(forKey: BioFrame.uid.key)
        
        self.number.text = "\(uid)"
        self.name.text = Utils.getName(for: uid)
        self.heartRate.text = "\(item.int(forKey: BioFrame.heartRate.key))"
        self.temperature.text = "\(item.double(forKey: BioFrame.predictedCoreTemp.key).print(to: 1))℃"
    }
    
}

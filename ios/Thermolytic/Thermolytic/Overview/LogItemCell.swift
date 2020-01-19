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
    
    func configure(item: Result) {
        uid = item.int(forKey: BioFrame.uid.key)
        
        self.number.text = "\(uid)"
        self.name.text = "\(item.string(forKey: Athlete.name.key) ?? "")"
        self.heartRate.text = "\(item.int(forKey: BioFrame.heartRate.key))"
        self.temperature.text = "\((item.double(forKey: BioFrame.predictedCoreTemp.key) + 2.0).print(to: 1))℃"
    }
    
}

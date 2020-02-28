//
//  LogItemCell.swift
//  Thermolytic
//
//  Created by Sam Yuyitung on 2019-11-20.
//  Copyright © 2019 Sam Yuyitung. All rights reserved.
//


import UIKit
import CouchbaseLiteSwift


protocol LogItemCellDelegate {
    func didPressDetail(for cell: LogItemCell)
}

class LogItemCell: UICollectionViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var number: UILabel!
    @IBOutlet weak var heartRate: UILabel!
    @IBOutlet weak var temperature: UILabel!
    @IBAction func didPressDetail(_ sender: Any) {
        delegate?.didPressDetail(for: self)
    }
    
    var uid: String? = nil
    var delegate: LogItemCellDelegate? = nil
    
    
    func configure(user: Result, frame: Result?) {
        uid = user.getId()
        
        self.number.text = "\(user.int(forKey: Athlete.number.key))"
        self.name.text = "\(user.string(forKey: Athlete.name.key) ?? "")"
        if let frame = frame {
            self.heartRate.text = "\(frame.int(forKey: BioFrame.heartRate.key))"
            self.temperature.text = "\((frame.float(forKey: BioFrame.predictedCoreTemp.key)).print(to: 1))℃"
        }
    }
    
}

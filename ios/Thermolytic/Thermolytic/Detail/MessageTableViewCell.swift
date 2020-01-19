//
//  MessageTableViewCell.swift
//  Thermolytic
//
//  Created by Sam Yuyitung on 2019-11-20.
//  Copyright © 2019 Sam Yuyitung`. All rights reserved.
//

import Foundation
import UIKit
import CouchbaseLiteSwift

class MessageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var timestamp: UILabel!
    @IBOutlet weak var message: UILabel!
    
    func configure(for item: Result) {
        assert(item.string(forKey: BaseDocument.type.key) == BioFrame.TYPE)
        
        self.message.text =
"""
        HR: \(item.int(forKey: BioFrame.heartRate.key)) bpm
        skin temp: \(item.double(forKey: BioFrame.skinTemp.key).print(to: 1))℃
        ambient temp: \(item.double(forKey: BioFrame.ambientTemp.key).print(to: 1))℃
        ambient humidity: \(item.double(forKey: BioFrame.ambientHumidity.key))%
        ==> core temp: \((item.double(forKey: BioFrame.predictedCoreTemp.key) + 2.0).print(to: 1))℃
"""
        let createdAt = item.double(forKey: BioFrame.createdAt.key)
        self.timestamp.text = Date(timeIntervalSince1970: createdAt).toString()

    }
}

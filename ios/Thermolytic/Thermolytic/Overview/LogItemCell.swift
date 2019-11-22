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
    
    @IBOutlet weak var user: UILabel!
    @IBOutlet weak var timestamp: UILabel!
    @IBOutlet weak var message: UILabel!
    
    var uid: Int = -1
    
    
    func configure(for item: Result) {
        
        uid = item.int(forKey: BleMessage.uid.key)
        
        self.user.text = "User \(item.int(forKey: BleMessage.uid.key))"
        self.message.text = item.string(forKey: BleMessage.message.key)
        let createdAt = item.double(forKey: BleMessage.createdAt.key)
        self.timestamp.text = Date(timeIntervalSince1970: createdAt).toString()
    }
    
}

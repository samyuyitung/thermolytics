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
        assert(item.string(forKey: BaseDocument.type.key) == BleMessage.TYPE)
        
        self.message.text = item.string(forKey: BleMessage.message.key)
        let createdAt = item.double(forKey: BleMessage.createdAt.key)
        self.timestamp.text = Date(timeIntervalSince1970: createdAt).toString()

    }
}

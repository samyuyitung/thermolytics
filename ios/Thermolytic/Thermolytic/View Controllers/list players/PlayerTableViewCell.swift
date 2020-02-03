//
//  PlayerTableViewCell.swift
//  Thermolytic
//
//  Created by Sam Yuyitung on 2020-01-21.
//  Copyright © 2020 Sam Yuyitung. All rights reserved.
//

import UIKit
import CouchbaseLiteSwift

class PlayerTableViewCell: UITableViewCell {
    
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
        
    var uid: String?

    func configure(for item: Result) {
        uid = item.getId()

        numberLabel.text = "\(item.int(forKey: Athlete.number.key))"
        nameLabel.text = item.string(forKey: Athlete.name.key)
    }
}

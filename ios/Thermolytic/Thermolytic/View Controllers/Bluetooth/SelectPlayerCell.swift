//
//  SelectPlayerCell.swift
//  Thermolytic
//
//  Created by Sam Yuyitung on 2020-03-10.
//  Copyright © 2020 Sam Yuyitung. All rights reserved.
//


import UIKit
import CouchbaseLiteSwift

class SelectPlayerCell: UITableViewCell {
    
    @IBOutlet weak var playerLabel: UILabel!
    
    func configure(for result: Result) {
        let number = result.int(forKey: Athlete.number.key)
        let name = result.string(forKey: Athlete.name.key) ?? ""
        
        playerLabel.text = "\(number) \(name.uppercased())"
    }
    
}

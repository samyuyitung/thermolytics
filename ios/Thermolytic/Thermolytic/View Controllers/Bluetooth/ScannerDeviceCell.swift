//
//  ScannerDeviceCell.swift
//  Thermolytic
//
//  Created by Sam Yuyitung on 2020-03-10.
//  Copyright © 2020 Sam Yuyitung. All rights reserved.
//

import UIKit
import CouchbaseLiteSwift

class ScannerDeviceCell: UITableViewCell {
    
    @IBOutlet weak var checkImage: UIImageView!
    @IBOutlet weak var playerLabel: UILabel!
    @IBOutlet weak var deviceLabel: UILabel!
    
    var deviceId: String? = nil
    
    func configure(deviceName: String, athlete: Document? = nil) {
        self.deviceId = deviceName
        self.deviceLabel.text = deviceName
        
        if let athlete = athlete {
            let number = athlete.int(forKey: Athlete.number.key)
            let name = athlete.string(forKey: Athlete.name.key) ?? ""
            

            playerLabel.text = "#\(number) \(name.uppercased())"
            playerLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 14.0)
            checkImage.isHidden = false
        } else {
            playerLabel.text = "Not Connected"
            playerLabel.font = UIFont(name: "HelveticaNeue ", size: 14.0)
            checkImage.isHidden = true
        }
    }
}

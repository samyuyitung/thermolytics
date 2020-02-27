//
//  BioFrameDebuggerCell.swift
//  Thermolytic
//
//  Created by Sam Yuyitung on 2020-02-06.
//  Copyright © 2020 Sam Yuyitung. All rights reserved.
//

import UIKit
import CouchbaseLiteSwift

class BioFrameDebuggerCell: UITableViewCell {
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var data: UILabel!

    
    func configure(with result: Result) {
        let createdTime = result.double(forKey: BioFrame.createdAt.key)
        time.text = Date(timeIntervalSince1970: createdTime).relativeTime
        
        data.text = """
        arm temp: \(result.float(forKey: BioFrame.armSkinTemp.key))
        leg temp: \(result.float(forKey: BioFrame.legSkinTemp.key))
        avg temp: \(result.float(forKey: BioFrame.avgSkinTemp.key))
        heart rate: \(result.float(forKey: BioFrame.heartRate.key))
        ambient temp: \(result.float(forKey: BioFrame.ambientTemp.key))
        ambient humidity: \(result.float(forKey: BioFrame.ambientHumidity.key))
        core temp: \(result.float(forKey: BioFrame.predictedCoreTemp.key))
        Acceleration X: \(result.float(forKey: BioFrame.xAcceleration.key))
        Acceleration y: \(result.float(forKey: BioFrame.yAcceleration.key))
        """
    }
}

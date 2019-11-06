//
//  BiometricsFrame.swift
//  Todo
//
//  Created by Sam Yuyitung on 2019-11-05.
//  Copyright © 2019 Couchbase. All rights reserved.
//

import Foundation
import CouchbaseLiteSwift


struct Accelerometer {
    var x: Float
    var y: Float
    var z: Float
}

class BiometricsFrame: BaseDocument {
    static let TYPE = "bioframe"
    static let heartRate = BasicProperty(key: "heart-rate")
    static let skinTemp = BasicProperty(key: "skin-temp")
    static let accelerometer = BasicProperty(key: "accelerometer")
    
    static func create (ts: Double, heartRate: Float, skinTemp: Float, accelerometer: Accelerometer) -> MutableDocument {
        let doc = MutableDocument()
        doc.setValue(TYPE, forKey: type.key)
        doc.setValue(ts, forKey: createdAt.key)
        
        doc.setValue(heartRate, forKey: self.heartRate.key)
        doc.setValue(skinTemp, forKey: self.skinTemp.key)
        let accData = ["x": accelerometer.x, "y": accelerometer.y, "z": accelerometer.z, ]
        doc.setValue(accData, forKey: self.accelerometer.key)
        return doc
    }

}

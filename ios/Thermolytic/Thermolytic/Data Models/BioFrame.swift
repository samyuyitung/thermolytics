//
//  BioFrame.swift
//  Thermolytic
//
//  Created by Sam Yuyitung on 2019-11-27.
//  Copyright © 2019 Sam Yuyitung. All rights reserved.
//

import Foundation
import CouchbaseLiteSwift

class BioFrame: BaseDocument {
    static let TYPE = "bio-frame"
    
    static let uid = BasicProperty(key: "uid")
    static let heartRate = BasicProperty(key: "heart-rate")
    static let skinTemp = BasicProperty(key: "skin-temp")
    static let ambientTemp = BasicProperty(key: "ambient-temp")
    static let ambientHumidity = BasicProperty(key: "ambient-humidity")
    static let predictedCoreTemp = BasicProperty(key: "predicted-core-temp")
    
    static let selectAll = [
        type.selectResult,
        createdAt.selectResult,
        id.selectResult,
        uid.selectResult,
        heartRate.selectResult,
        skinTemp.selectResult,
        ambientTemp.selectResult,
        ambientHumidity.selectResult,
        predictedCoreTemp.selectResult
    ]
    
    static func selectAll(from alias: String) -> [SelectResultAs] {
        return [
            type.selectResult(from: alias),
            createdAt.selectResult(from: alias),
            id.selectResult(from: alias),
            uid.selectResult(from: alias),
            heartRate.selectResult(from: alias),
            skinTemp.selectResult(from: alias),
            ambientTemp.selectResult(from: alias),
            ambientHumidity.selectResult(from: alias),
            predictedCoreTemp.selectResult(from: alias)
        ]
    }
    
    
    static func createFromMessage(uid sUid: String, /* String */
        heartRate sHeartRate: String, /* Int */
        skinTemp sSkinTemp: String, /* Double */
        ambientTemp sAmbientTemp: String, /* Double */
        ambientHumidity sAmbientHumidity: String, /* Double */
        predictedCoreTemp: Double) -> MutableDocument? {
        
        // TODO - Add more checks
        
        guard let heartRate = Int(sHeartRate) else {
            Utils.log(at: .Error, msg: "Could not parse hr as Int -- {\(sHeartRate)}")
            return nil
        }
        guard let skinTemp = Double(sSkinTemp) else {
            Utils.log(at: .Error, msg: "Could not parse skinTemp as Double -- {\(sSkinTemp)}")
            return nil
        }
        guard let ambientTemp = Double(sAmbientTemp) else {
            Utils.log(at: .Error, msg: "Could not parse ambientTemp as Double -- {\(sAmbientTemp)}")
            return nil
        }
        guard let ambientHumidity = Double(sAmbientHumidity) else {
            Utils.log(at: .Error, msg: "Could not parse ambientHumidity as Double -- {\(sAmbientHumidity)}")
            return nil
        }
        
        let now = Date().timeIntervalSince1970
        let doc = MutableDocument()
        doc.setValue(TYPE, forKey: self.type.key)
        doc.setValue(now, forKey: createdAt.key)
        
        doc.setValue(uid, forKey: self.uid.key)
        doc.setValue(heartRate, forKey: self.heartRate.key)
        doc.setValue(skinTemp, forKey: self.skinTemp.key)
        doc.setValue(ambientTemp, forKey: self.ambientTemp.key)
        doc.setValue(ambientHumidity, forKey: self.ambientHumidity.key)
        doc.setValue(predictedCoreTemp, forKey: self.predictedCoreTemp.key)
        
        return doc
    }
    
    static func create(uid: String,
                       heartRate: Int,
                       skinTemp: Double,
                       ambientTemp: Double,
                       ambientHumidity: Double,
                       predictedCoreTemp: Double) -> MutableDocument? {
        
        let now = Date().timeIntervalSince1970
        let doc = MutableDocument()
        doc.setValue(TYPE, forKey: self.type.key)
        doc.setValue(now, forKey: createdAt.key)
        
        doc.setValue(uid, forKey: self.uid.key)
        doc.setValue(heartRate, forKey: self.heartRate.key)
        doc.setValue(skinTemp, forKey: self.skinTemp.key)
        doc.setValue(ambientTemp, forKey: self.ambientTemp.key)
        doc.setValue(ambientHumidity, forKey: self.ambientHumidity.key)
        doc.setValue(predictedCoreTemp, forKey: self.predictedCoreTemp.key)
        
        return doc
    }
    
    
    static func create(now: TimeInterval,
                       uid: String,
                       heartRate: Int,
                       skinTemp: Double,
                       ambientTemp: Double,
                       ambientHumidity: Double,
                       predictedCoreTemp: Double) -> MutableDocument? {
        
        //        let now = Date().timeIntervalSince1970
        let doc = MutableDocument()
        doc.setValue(TYPE, forKey: self.type.key)
        doc.setValue(now, forKey: createdAt.key)
        
        doc.setValue(uid, forKey: self.uid.key)
        doc.setValue(heartRate, forKey: self.heartRate.key)
        doc.setValue(skinTemp, forKey: self.skinTemp.key)
        doc.setValue(ambientTemp, forKey: self.ambientTemp.key)
        doc.setValue(ambientHumidity, forKey: self.ambientHumidity.key)
        doc.setValue(predictedCoreTemp, forKey: self.predictedCoreTemp.key)
        
        return doc
    }
}

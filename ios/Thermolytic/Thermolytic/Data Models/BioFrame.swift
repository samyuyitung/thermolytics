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
    static let session = BasicProperty(key: "session")
    static let heartRate = BasicProperty(key: "heart-rate")
    static let armSkinTemp = BasicProperty(key: "arm-skin-temp")
    static let legSkinTemp = BasicProperty(key: "leg-skin-temp")
    static let avgSkinTemp = BasicProperty(key: "avg-skin-temp")
    static let ambientTemp = BasicProperty(key: "ambient-temp")
    static let ambientHumidity = BasicProperty(key: "ambient-humidity")
    static let predictedCoreTemp = BasicProperty(key: "predicted-core-temp")
    
    static private let all = [
        type,
        createdAt,
        id,
        uid,
        session,
        heartRate,
        armSkinTemp,
        legSkinTemp,
        avgSkinTemp,
        ambientTemp,
        ambientHumidity,
        predictedCoreTemp
    ]
    
    static let selectAll: [SelectResultAs] = {
       return all.map { it in it.selectResult }
    }()
    
    
    static func selectAll(from alias: String) -> [SelectResultAs] {
        return all.map { it in it.selectResult(from: alias) }
    }
    
    static func create(uid: String,
                       heartRate: Int,
                       armSkinTemp: Double,
                       legSkinTemp: Double,
                       avgSkinTemp: Double,
                       ambientTemp: Double,
                       ambientHumidity: Double,
                       predictedCoreTemp: Double,
                       session: String = "now") -> MutableDocument? {
        
        let now = Date().timeIntervalSince1970
        let doc = MutableDocument()
        doc.setValue(TYPE, forKey: self.type.key)
        doc.setValue(now, forKey: createdAt.key)
        
        doc.setValue(uid, forKey: self.uid.key)
        doc.setValue(session, forKey: self.session.key)
        doc.setValue(heartRate, forKey: self.heartRate.key)
        doc.setValue(armSkinTemp, forKey: self.armSkinTemp.key)
        doc.setValue(legSkinTemp, forKey: self.legSkinTemp.key)
        doc.setValue(avgSkinTemp, forKey: self.avgSkinTemp.key)
        doc.setValue(ambientTemp, forKey: self.ambientTemp.key)
        doc.setValue(ambientHumidity, forKey: self.ambientHumidity.key)
        doc.setValue(predictedCoreTemp, forKey: self.predictedCoreTemp.key)
        
        return doc
    }
    
    // For debugger
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
        doc.setValue(armSkinTemp, forKey: self.armSkinTemp.key)
        doc.setValue(legSkinTemp, forKey: self.legSkinTemp.key)
        doc.setValue(avgSkinTemp, forKey: self.avgSkinTemp.key)
        doc.setValue(ambientTemp, forKey: self.ambientTemp.key)
        doc.setValue(ambientHumidity, forKey: self.ambientHumidity.key)
        doc.setValue(predictedCoreTemp, forKey: self.predictedCoreTemp.key)
        
        return doc
    }
}

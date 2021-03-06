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

    enum SessionType: String, CaseIterable {
        case training = "Training"
        case game = "Game"
        
        init?(id: Int) {
            switch id {
            case 0: self = .training
            case 1: self = .game
            default: return nil
            }
        }
    }
    
    static let missingDefault = -100.0
    static let TYPE = "bio-frame"
    
    static let deviceId = BasicProperty(key: "device-id")
    static let uid = BasicProperty(key: "uid")
    static let session = BasicProperty(key: "session")
    static let sessionType = BasicProperty(key: "session-type")
    static let heartRate = BasicProperty(key: "heart-rate")
    static let armSkinTemp = BasicProperty(key: "arm-skin-temp")
    static let legSkinTemp = BasicProperty(key: "leg-skin-temp")
    static let avgSkinTemp = BasicProperty(key: "avg-skin-temp")
    static let xAcceleration = BasicProperty(key: "accelerationX")
    static let yAcceleration = BasicProperty(key: "accelerationY")
    static let xVelocity = BasicProperty(key: "velocityX")
    static let yVelocity = BasicProperty(key: "velocityY")
    static let distanceTraveled = BasicProperty(key: "distance")
    static let ambientTemp = BasicProperty(key: "ambient-temp")
    static let ambientHumidity = BasicProperty(key: "ambient-humidity")
    static let predictedCoreTemp = BasicProperty(key: "predicted-core-temp")
    
    static let all = [
        type,
        createdAt,
        id,
        uid,
        session,
        sessionType,
        heartRate,
        armSkinTemp,
        legSkinTemp,
        avgSkinTemp,
        xAcceleration,
        yAcceleration,
        ambientTemp,
        ambientHumidity,
        predictedCoreTemp,
        xVelocity,
        yVelocity,
        distanceTraveled
    ]
    
    static let selectAll: [SelectResultAs] = {
       return all.map { it in it.selectResult }
    }()
    
    
    static func selectAll(from alias: String) -> [SelectResultAs] {
        return all.map { it in it.selectResult(from: alias) }
    }
    
    static func create(deviceId: String,
                       uid: String,
                       heartRate: Int,
                       armSkinTemp: Double,
                       legSkinTemp: Double,
                       avgSkinTemp: Double,
                       acceleration: Point,
                       velocity: Point,
                       distance: Double,
                       ambientTemp: Double,
                       ambientHumidity: Double,
                       predictedCoreTemp: Double,
                       session: String,
                       sessionType: SessionType = .training,
                       createdAt now: TimeInterval = Date().timeIntervalSince1970) -> MutableDocument? {
        
        
        let doc = MutableDocument()
        doc.setValue(TYPE, forKey: self.type.key)
        doc.setValue(now, forKey: createdAt.key)
        
        doc.setValue(deviceId, forKey: self.deviceId.key)
        doc.setValue(uid, forKey: self.uid.key)
        doc.setValue(session, forKey: self.session.key)
        doc.setValue(sessionType.rawValue, forKey: self.sessionType.key)
        doc.setValue(heartRate, forKey: self.heartRate.key)
        doc.setValue(armSkinTemp, forKey: self.armSkinTemp.key)
        doc.setValue(legSkinTemp, forKey: self.legSkinTemp.key)
        doc.setValue(avgSkinTemp, forKey: self.avgSkinTemp.key)
        doc.setValue(acceleration.x, forKey: self.xAcceleration.key)
        doc.setValue(acceleration.y, forKey: self.yAcceleration.key)
        doc.setValue(velocity.x, forKey: self.xVelocity.key)
        doc.setValue(velocity.y, forKey: self.yVelocity.key)
        doc.setValue(distance, forKey: self.distanceTraveled.key)
        doc.setValue(ambientTemp, forKey: self.ambientTemp.key)
        doc.setValue(ambientHumidity, forKey: self.ambientHumidity.key)
        doc.setValue(predictedCoreTemp, forKey: self.predictedCoreTemp.key)
        
        return doc
    }
}

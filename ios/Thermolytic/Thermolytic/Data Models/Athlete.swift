//
//  Athlete.swift
//  Thermolytic
//
//  Created by Sam Yuyitung on 2020-01-18.
//  Copyright © 2020 Sam Yuyitung. All rights reserved.
//

import Foundation
import CouchbaseLiteSwift


class Athlete : BaseDocument {
    
    enum Position: String, CaseIterable {
        case forward = "Forward"
        case defense = "Defense"
        
        init?(id : Int) {
            switch id {
            case 0: self = .forward
            case 1: self = .defense
            default: return nil
            }
        }
    }
    
    //0.5, 1.0, 1.5, 2.0, 2.5, 3.0, and 3.5
    enum Classification: Float, CaseIterable {
        case zero_five = 0.5
        case one = 1
        case one_five = 1.5
        case two = 2
        case two_five = 2.5
        case three = 3
        case three_five = 3.5
        
        init?(id : Int) {
            if let classification = Classification(rawValue: (Float(id + 1) * 0.5)) {
                self = classification
            }
            return nil
        }
        
        func val() -> Float {
            return self.rawValue
        }
    }
    
    static let maxHrDefault = 160
    static let thresholdTempDefault = 39.4
    
    static let TYPE = "athlete"
    static let number = BasicProperty(key: "number")
    static let name = BasicProperty(key: "name")
    static let classification = BasicProperty(key: "classification")
    static let weight = BasicProperty(key: "weight")
    static let height = BasicProperty(key: "height")
    static let dob = BasicProperty(key: "dob")
    static let position = BasicProperty(key: "position")
    static let team = BasicProperty(key: "team")
    static let maxHr = BasicProperty(key: "max-hr")
    static let thresholdTemp = BasicProperty(key: "threshold-temp")
    static let maxSpeed = BasicProperty(key: "max-speed")
    
    static let all = [
         id,
         type,
         createdAt,
         number,
         name,
         classification,
         weight,
         height,
         dob,
         position,
         team,
         maxHr,
         thresholdTemp,
         maxSpeed]
    
    static let selectAll: [SelectResultAs] = {
        return all.map { it in it.selectResult }
    }()
    
    static func selectAll(from alias: String) -> [SelectResultAs] {
        return all.map { it in it.selectResult(from: alias) }
    }
    
    static func create(from values: EditPlayerFields) -> MutableDocument {
        return create(number: values.number, name: values.name, classification: values.classification, weight: values.weight, dob: values.dob, position: values.position, height: values.height, maxHr: values.maxHr, thresholdTemp: values.thresholdTemp)
    }
    
    static func create(number: Int,
                       name: String,
                       classification: Classification,
                       weight: Float,
                       dob: Date,
                       position: Athlete.Position,
                       height: Float,
                       maxHr: Int,
                       thresholdTemp: Float,
                       maxSpeed: Float = 10.0) -> MutableDocument {
        
        let now = Date().timeIntervalSince1970
        let doc = MutableDocument()
        doc.setString(TYPE, forKey: self.type.key)
        doc.setDouble(now, forKey: createdAt.key)
        
        doc.setString(name, forKey: self.name.key)
        doc.setInt(number, forKey: self.number.key)
        doc.setFloat(weight, forKey: self.weight.key)
        doc.setFloat(classification.rawValue, forKey: self.classification.key)
        doc.setDouble(dob.timeIntervalSince1970, forKey: self.dob.key)
        doc.setString(position.rawValue, forKey: self.position.key)
        doc.setFloat(thresholdTemp, forKey: self.thresholdTemp.key)
        doc.setFloat(height, forKey: self.height.key)
        doc.setInt(maxHr, forKey: self.maxHr.key)
        doc.setFloat(maxSpeed, forKey: self.maxSpeed.key)
        
        return doc
    }
    
    static func toEditFields(from doc: Document) -> EditPlayerFields {
        return EditPlayerFields(name: doc.string(forKey: name.key) ?? "",
                                number: doc.int(forKey: number.key),
                                dob: Date(timeIntervalSince1970: doc.double(forKey: dob.key)),
                                classification: Classification(rawValue: doc.float(forKey: classification.key)) ?? .zero_five,
                                weight: doc.float(forKey: weight.key),
                                position: Position(rawValue: doc.string(forKey: position.key) ?? "") ?? .forward,
                                height: doc.float(forKey: height.key),
                                maxHr: doc.int(forKey: maxHr.key),
                                thresholdTemp: doc.float(forKey: thresholdTemp.key))
    }
    
    static func update(doc: MutableDocument, with values: EditPlayerFields) {
        doc.setString(values.name, forKey: self.name.key)
        doc.setInt(values.number, forKey: self.number.key)
        doc.setFloat(values.weight, forKey: self.weight.key)
        doc.setFloat(values.classification.rawValue, forKey: self.classification.key)
        doc.setDouble(values.dob.timeIntervalSince1970, forKey: self.dob.key)
        doc.setString(values.position.rawValue, forKey: self.position.key)
        doc.setFloat(values.thresholdTemp, forKey: self.thresholdTemp.key)
        doc.setFloat(values.height, forKey: self.height.key)
        doc.setInt(values.maxHr, forKey: self.maxHr.key)
        doc.setFloat(values.maxSpeed, forKey: self.maxSpeed.key)
    }
    
    static func deleteAllData(for uid: String) {
        let types = [PlayerNote.TYPE, BioFrame.TYPE].map { (type) -> ExpressionProtocol in Expression.string(type) }
        let uids = [PlayerNote.uid, BioFrame.uid].map { field -> ExpressionProtocol in field.expression }
        
        let deleteQuery = QueryBuilder.select(BaseDocument.id.selectResult)
            .from(DataSource.database(DatabaseUtil.shared))
            .where(BaseDocument.type.expression.in(types).and(Expression.string(uid).in(uids)))
        
        do {
            let rows = try deleteQuery.execute()
            
            try DatabaseUtil.shared.inBatch {
                for row in rows {
                    if let id = row.getId() {
                        try DatabaseUtil.deleteDocumentWith(id: id)
                    }
                }
            }
        } catch {
            Utils.log(at: .Error, msg: "oops \(error)")
        }
    }
}

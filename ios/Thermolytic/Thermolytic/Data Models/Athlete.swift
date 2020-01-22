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
    
    enum Position: String {
        case forward = "Forward"
        case defense = "Defense"
    }
    
    static let TYPE = "athlete"
    
    static let number = BasicProperty(key: "number")
    static let name = BasicProperty(key: "name")
    static let height = BasicProperty(key: "height")
    static let weight = BasicProperty(key: "weight")
    static let age = BasicProperty(key: "age")
    static let position = BasicProperty(key: "position")
    
    
    static let selectAll = [
        id.selectResult,
        type.selectResult,
        createdAt.selectResult,
        number.selectResult,
        name.selectResult,
        height.selectResult,
        weight.selectResult,
        age.selectResult,
        position.selectResult
    ]
    
    static func selectAll(from alias: String) -> [SelectResultAs] {
        return [
            id.selectResult(from: alias),
            type.selectResult(from: alias),
            createdAt.selectResult(from: alias),
            number.selectResult(from: alias),
            name.selectResult(from: alias),
            height.selectResult(from: alias),
            weight.selectResult(from: alias),
            age.selectResult(from: alias),
            position.selectResult(from: alias)
        ]
    }
    
    static func create(from values: EditPlayerFields) -> MutableDocument {
        return create(number: values.number, name: values.name, height: values.height, weight: values.height, age: values.age, position: values.position)
    }

    static func create(number: Int,
                       name: String,
                       height: Float,
                       weight: Float,
                       age: Int,
                       position: Athlete.Position) -> MutableDocument {
        
        let now = Date().timeIntervalSince1970
        let doc = MutableDocument()
        doc.setString(TYPE, forKey: self.type.key)
        doc.setDouble(now, forKey: createdAt.key)
        
        doc.setString(name, forKey: self.name.key)
        doc.setInt(number, forKey: self.number.key)
        doc.setFloat(weight, forKey: self.weight.key)
        doc.setFloat(height, forKey: self.height.key)
        doc.setInt(age, forKey: self.age.key)
        doc.setString(position.rawValue, forKey: self.position.key)
        
        return doc
    }
    
    static func toEditFields(from doc: Document) -> EditPlayerFields {
        return EditPlayerFields(name: doc.string(forKey: name.key) ?? "",
                                number: doc.int(forKey: number.key),
                                age:  doc.int(forKey: age.key),
                                height: doc.float(forKey: height.key),
                                weight: doc.float(forKey: weight.key),
                                position: Position(rawValue: doc.string(forKey: position.key) ?? "") ?? .forward)
    }
    
    static func update(doc: MutableDocument, with values: EditPlayerFields) {
        doc.setString(values.name, forKey: self.name.key)
        doc.setInt(values.number, forKey: self.number.key)
        doc.setFloat(values.weight, forKey: self.weight.key)
        doc.setFloat(values.height, forKey: self.height.key)
        doc.setInt(values.age, forKey: self.age.key)
        doc.setString(values.position.rawValue, forKey: self.position.key)
    }
    
    static func deleteAllData(for uid: String) {
        let types = [PlayerNote.TYPE, BioFrame.TYPE, BleMessage.TYPE].map { (type) -> ExpressionProtocol in Expression.string(type) }
        let uids = [PlayerNote.uid, BioFrame.uid, BleMessage.uid].map { field -> ExpressionProtocol in field.expression }
    
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

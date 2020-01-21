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
        doc.setValue(TYPE, forKey: self.type.key)
        doc.setValue(now, forKey: createdAt.key)
        
        doc.setValue(name, forKey: self.name.key)
        doc.setValue(number, forKey: self.number.key)
        doc.setValue(weight, forKey: self.weight.key)
        doc.setValue(height, forKey: self.height.key)
        doc.setValue(age, forKey: self.age.key)
        doc.setValue(position.rawValue, forKey: self.position.key)
        
        return doc
    }
    
    
}

//
//  User.swift
//  Thermolytic
//
//  Created by Sam Yuyitung on 2020-01-18.
//  Copyright © 2020 Sam Yuyitung. All rights reserved.
//

import Foundation
import CouchbaseLiteSwift

class Athlete : BaseDocument {
    static let TYPE = "user"
    
    static let uid = BasicProperty(key: "uid")
    static let name = BasicProperty(key: "name")
    static let height = BasicProperty(key: "height")
    static let weight = BasicProperty(key: "weight")
    
    static let selectAll = [
        id.selectResult,
        type.selectResult,
        createdAt.selectResult,
        uid.selectResult,
        name.selectResult,
        height.selectResult,
        weight.selectResult
    ]
    
    static func selectAll(from alias: String) -> [SelectResultAs] {
        return [
            id.selectResult(from: alias),
            type.selectResult(from: alias),
            createdAt.selectResult(from: alias),
            uid.selectResult(from: alias),
            name.selectResult(from: alias),
            height.selectResult(from: alias),
            weight.selectResult(from: alias)
        ]
    }
    
    static func create(uid: Int,
                       name: String,
                       height: Float,
                       weight: Float) -> MutableDocument {
        
        let now = Date().timeIntervalSince1970
        let doc = MutableDocument()
        doc.setValue(TYPE, forKey: self.type.key)
        doc.setValue(now, forKey: createdAt.key)
        
        doc.setValue(uid, forKey: self.uid.key)
        doc.setValue(name, forKey: self.name.key)
        doc.setValue(weight, forKey: self.weight.key)
        doc.setValue(height, forKey: self.height.key)
        
        return doc
    }
    
    
}

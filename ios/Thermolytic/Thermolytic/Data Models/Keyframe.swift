//
//  Keyframe.swift
//  Thermolytic
//
//  Created by Sam Yuyitung on 2020-03-05.
//  Copyright © 2020 Sam Yuyitung. All rights reserved.
//

import Foundation
import CouchbaseLiteSwift

class Keyframe: BaseDocument {
    static let TYPE = "Keyframe"
    
    static let name = BasicProperty(key: "name")
    static let session = BasicProperty(key: "session")
    
    static let selectAll = [
        id.selectResult,
        type.selectResult,
        createdAt.selectResult,
        name.selectResult,
        session.selectResult
    ]
    
    static func create(name: String, session: String) -> MutableDocument  {
        
        let now = Date().timeIntervalSince1970
        let doc = MutableDocument()
        doc.setString(TYPE, forKey: self.type.key)
        doc.setDouble(now, forKey: createdAt.key)
        
        doc.setString(name, forKey: self.name.key)
        doc.setString(session, forKey: self.session.key)
        
        return doc
    }
}

//
//  PlayerNote.swift
//  Thermolytic
//
//  Created by Sam Yuyitung on 2020-01-20.
//  Copyright © 2020 Sam Yuyitung. All rights reserved.
//

import CouchbaseLiteSwift


class PlayerNote: BaseDocument {
    static let TYPE = "player-note"
    
    static let uid = BasicProperty(key: "uid")
    static let note = BasicProperty(key: "note")

    static let selectAll = [
        id.selectResult,
        type.selectResult,
        createdAt.selectResult,
        uid.selectResult,
        note.selectResult
    ]
    
    static func create(uid: String, note: String) -> MutableDocument  {
        
        let now = Date().timeIntervalSince1970
        let doc = MutableDocument()
        doc.setString(TYPE, forKey: self.type.key)
        doc.setDouble(now, forKey: createdAt.key)
        
        doc.setString(uid, forKey: self.uid.key)
        doc.setString(note, forKey: self.note.key)
        
        return doc
    }
}


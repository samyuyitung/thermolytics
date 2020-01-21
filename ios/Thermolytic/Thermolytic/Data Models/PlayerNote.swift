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
    static let note = BasicProperty(key: "uid")

    static let selectAll = [
        id.selectResult,
        type.selectResult,
        createdAt.selectResult,
        uid.selectResult,
        note.selectResult
    ]
    
    static func create(uid: Int, note: String) -> MutableDocument  {
        
        let now = Date().timeIntervalSince1970
        let doc = MutableDocument()
        doc.setValue(TYPE, forKey: self.type.key)
        doc.setValue(now, forKey: createdAt.key)
        
        doc.setValue(uid, forKey: self.uid.key)
        doc.setValue(note, forKey: self.note.key)
        
        return doc
    }
}


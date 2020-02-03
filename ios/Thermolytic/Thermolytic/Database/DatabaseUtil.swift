//
//  DatabaseUtil.swift
//  Todo
//
//  Created by Sam Yuyitung on 2019-11-05.
//  Copyright © 2019 Couchbase. All rights reserved.
//

import Foundation
import CouchbaseLiteSwift

class DatabaseUtil {
    
    static var shared: Database {
        return App.shared
    }

    static func insert(doc: MutableDocument) -> Bool {
        do {
            try shared.saveDocument(doc)
            return true
        } catch {
            Utils.log(at: .Error, msg: "did not insert")
            return false
        }
    }
    
   static func openDatabase(username:String) throws {
        let config = DatabaseConfiguration()
        App.shared = try Database(name: username, config: config)
    }

    static func closeDatabase() throws {
        try shared.close()
    }
 
    
    
    static func deleteDocumentWith(id: String) throws {
        if let doc = App.shared.document(withID: id) {
            try App.shared.deleteDocument(doc)
        }
    }
    
    static func clearAllOf(type: String) {
        let query = QueryBuilder.select(BaseDocument.id.selectResult)
            .from(DataSource.database(shared))
        .where(BaseDocument.type.expression.equalTo(Expression.string(type)))
        
        do {
            let res = try query.execute()
            for row in res.allResults() {
                if let id = row.value(at: 0) as? String {
                    try deleteDocumentWith(id: id)
                }
            }
        } catch {
            Utils.log(at: .Error, msg: "Error -- \(error)")
        }
    }
}

extension Query {
    func simpleListener(_ closure: @escaping ([Result]) -> Void) {
        addChangeListener { (change) in
            if let error = change.error {
                Utils.log(at: .Error, msg: "Error fetching data -- \(error)")
            }
            if let res = change.results {
                closure(res.allResults())
            }
        }
    }
}

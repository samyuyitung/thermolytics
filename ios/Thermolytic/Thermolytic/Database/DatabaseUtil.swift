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
    
    static let USER_DB = "users"
    
    static var shared: Database {
        return App.shared
    }

    static func insert(doc: MutableDocument, into database: Database = shared) -> Bool {
        do {
            try database.saveDocument(doc)
            return true
        } catch {
            Utils.log(at: .Error, msg: "did not insert")
            return false
        }
    }
    
   static func openDatabase(name: String) throws -> Database {
        return try Database(name: name, config: DatabaseConfiguration())
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
    func simpleListener(_ closure: @escaping ([Result]) -> Void) -> ListenerToken {
        return addChangeListener { (change) in
            if let error = change.error {
                Utils.log(at: .Error, msg: "Error fetching data -- \(error)")
            }
            if let res = change.results {
                closure(res.allResults())
            }
        }
    }
}

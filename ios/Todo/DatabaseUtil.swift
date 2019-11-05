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
    
   static var shared: Database!
    
   static func openDatabase(username:String) throws {
        
        let config = DatabaseConfiguration()
        DatabaseUtil.shared = try Database(name: username, config: config)
        createDatabaseIndex()
    }

    static func closeDatabase() throws {
        try DatabaseUtil.shared.close()
    }
 
    private static func createDatabaseIndex() {
        // For task list query:
        let type = ValueIndexItem.expression(Expression.property("type"))
        let name = ValueIndexItem.expression(Expression.property("name"))
        let taskListId = ValueIndexItem.expression(Expression.property("taskList.id"))
        let task = ValueIndexItem.expression(Expression.property("task"))
        
        do {
            let index = IndexBuilder.valueIndex(items: type, name)
            try DatabaseUtil.shared.createIndex(index, withName: "task-list")
        } catch let error as NSError {
            NSLog("Couldn't create index (type, name): %@", error);
        }
        
        // For tasks query:
        do {
            let index = IndexBuilder.valueIndex(items: type, taskListId, task)
            try DatabaseUtil.shared.createIndex(index, withName: "tasks")
        } catch let error as NSError {
            NSLog("Couldn't create index (type, taskList.id, task): %@", error);
        }
    }
    
    static func deleteDocumentWith(id: String) throws {
        if let doc = shared.document(withID: id) {
            try shared.deleteDocument(doc)
        }
    }
}

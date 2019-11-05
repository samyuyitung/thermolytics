//
//  Task.swift
//  Todo
//
//  Created by Sam Yuyitung on 2019-11-05.
//  Copyright © 2019 Couchbase. All rights reserved.
//

import Foundation
import CouchbaseLiteSwift

class Task: BaseDocument {
    static let TYPE:String  = "task"
    
    static let completed = BasicProperty(key: "completed")
    static let task = BasicProperty(key: "task")
    static let taskListId = BasicProperty(key: "task-list-id")
    
    static func create(taskListId: String, task: String, completed: Bool = false) -> MutableDocument {
        let doc = MutableDocument()
        doc.setValue(Task.TYPE, forKey: type.key)
        doc.setValue(Date(), forKey: createdAt.key)
        doc.setValue(taskListId, forKey: self.taskListId.key)
        
        doc.setValue(task, forKey: self.task.key)
        doc.setValue(completed, forKey: self.completed.key)
        
        return doc
    }
}

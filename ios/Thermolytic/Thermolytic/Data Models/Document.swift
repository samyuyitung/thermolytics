//
//  Document.swift
//  Thermolytic
//
//  Created by Sam Yuyitung on 2019-11-05.
//  Copyright © 2019 Couchbase. All rights reserved.
//

import Foundation
import CouchbaseLiteSwift

protocol Queryable {
    var expression: ExpressionProtocol { get}
    var selectResult: SelectResultAs { get }
}

// basic column type with only a name
class BasicProperty: Queryable {
    var key: String
    
    init(key: String) {
        self.key = key
    }
    
    var expression: ExpressionProtocol {
        get {
            return Expression.property(self.key)
        }
    }
    
    var selectResult: SelectResultAs {
        get {
            SelectResult.expression(self.expression)
        }
    }
    
    func expression(from alias: String) -> ExpressionProtocol {
        return Expression.property(self.key).from(alias)
    }

    func selectResult(from alias: String) -> SelectResultAs {
        return SelectResult.expression(self.expression(from: alias))
    }
}

class BaseDocument {
    static let id = BasicProperty(key: "_id")
    static let type = BasicProperty(key: "type")
    static let createdAt = BasicProperty(key: "createdAt")
}


extension Result {
    func getId() -> String? {
        return self.string(forKey: "id")
    }
}

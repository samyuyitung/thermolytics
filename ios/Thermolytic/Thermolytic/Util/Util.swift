//
//  Util.swift
//  Todo
//
//  Created by Sam Yuyitung on 2019-11-05.
//  Copyright © 2019 Couchbase. All rights reserved.
//

import Foundation

enum Level: Character {
    case Error = "❌"
    case Warning = "⚠️"
    case Info = "❔"
    case Debug = "🐞"
}

class Utils {
    static func log(at level: Level = .Debug, msg: String) {
        print("[\(Date())] [\(level)] - \(msg)")
    }
}



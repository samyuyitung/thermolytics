//
//  Misc+extensions.swift
//  Thermolytic
//
//  Created by Sam Yuyitung on 2019-11-20.
//  Copyright © 2019 Sam Yuyitung. All rights reserved.
//

import Foundation

// MARK: - Date

extension Date {
    func toString(format: String = "HH:mm:ss.SSS") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }

}

extension Data {
    internal var hexString: String {
        return map { String(format: "%02X", $0) }.joined()
    }
}

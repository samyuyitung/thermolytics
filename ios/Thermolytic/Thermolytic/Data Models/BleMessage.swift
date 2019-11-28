//
//  LogItem.swift
//  nRF Toolbox
//
//  Created by Mostafa Berg on 11/05/16.
//  Copyright © 2016 Nordic Semiconductor. All rights reserved.
//

import Foundation
import CouchbaseLiteSwift

enum MessageType: String {
    case Sent = "Sent"
    case Received = "Received"
}

class BleMessage: BaseDocument {
    static let TYPE = "ble-message"
    
    static let messageType = BasicProperty(key: "message-type")
    static let message = BasicProperty(key: "message")
    static let uid = BasicProperty(key: "uid")
    
    static func create(type messageType: MessageType, message: String, uid: Int) -> MutableDocument {
        let now = Date().timeIntervalSince1970
        let doc = MutableDocument()
        doc.setValue(TYPE, forKey: self.type.key)
        doc.setValue(now, forKey: createdAt.key)
        
        doc.setValue(messageType.rawValue, forKey: self.messageType.key)
        doc.setValue(message, forKey: self.message.key)
        doc.setValue(uid, forKey: self.uid.key)

        return doc
    }
}

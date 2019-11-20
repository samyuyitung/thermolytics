//
//  LogItemTableViewCell.swift
//  nRF Toolbox
//
//  Created by Mostafa Berg on 11/05/16.
//  Copyright © 2016 Nordic Semiconductor. All rights reserved.
//

import UIKit
import CouchbaseLiteSwift


class LogItemTableViewCell: UITableViewCell {

    //MARK: - Cell Outlets

    @IBOutlet weak var timestamp: UILabel!
    @IBOutlet weak var message: UILabel!
    
    //MARK: - Implementation
    func setItem(for item: Result){
        message.text = item.string(forKey: BleMessage.message.key)
        let createdAt = item.double(forKey: BleMessage.createdAt.key)
        timestamp.text = Date(timeIntervalSince1970: createdAt).toString()
        
        let messageType = MessageType(rawValue: item.string(forKey: BleMessage.messageType.key) ?? "") ?? .none
        let color : UIColor = {
        switch messageType {
        case .Sent:
            return UIColor.blue
        case .Received:
            return UIColor.red
        case .none:
            return UIColor.black
        }
        }()

        self.message.textColor = color
    }
}

extension Date
{
    func toString(format: String = "HH:mm:ss.SSS") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }

}

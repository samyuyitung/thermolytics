//
//  PlayerNoteTableViewCell.swift
//  Thermolytic
//
//  Created by Sam Yuyitung on 2020-01-20.
//  Copyright © 2020 Sam Yuyitung. All rights reserved.
//

import Foundation
import UIKit
import CouchbaseLiteSwift

class PlayerNoteTabelViewCell: UITableViewCell {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var note: UILabel!
    
    func configure(for item: Result) {
        assert(item.string(forKey: PlayerNote.type.key) == PlayerNote.TYPE)
        
        let createdAt = Date(timeIntervalSince1970: TimeInterval(item.int64(forKey: PlayerNote.createdAt.key)))
        
        timeLabel.text = createdAt.relativeTime
        note.text = item.string(forKey: PlayerNote.note.key)
    }
}

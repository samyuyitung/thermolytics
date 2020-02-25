//
//  AddNoteModalViewController.swift
//  Thermolytic
//
//  Created by Sam Yuyitung on 2020-02-03.
//  Copyright © 2020 Sam Yuyitung. All rights reserved.
//

import UIKit

class AddNoteModalViewController: UIViewController {
    @IBOutlet weak var noteView: UITextView!
    
    @IBAction func backgroundPressed(_ sender: Any) {
        self.dismiss(animated: true)

    }
    @IBAction func closeButtonPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    
    @IBAction func addNotePressed(_ sender: Any) {
        if let uid = uid, let note = noteView.text, !note.isEmpty {
            let doc = PlayerNote.create(uid: uid, note: note)
            let _ = DatabaseUtil.insert(doc: doc)
            self.dismiss(animated: true)
        }
    }
    
    var uid: String? = nil
}

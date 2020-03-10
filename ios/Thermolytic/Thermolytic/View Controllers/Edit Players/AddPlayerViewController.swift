//
//  AddPlayerViewController.swift
//  Thermolytic
//
//  Created by Sam Yuyitung on 2020-01-21.
//  Copyright © 2020 Sam Yuyitung. All rights reserved.
//

import UIKit


class AddPlayerViewController : UIViewController {
    @IBOutlet weak var editPlayerView: EditPlayerView!
    override func viewDidLoad() {
        editPlayerView.delegate = self
        editPlayerView.setupForType(isAdding: true)
    }
}

extension AddPlayerViewController : EditPlayerViewDelegate {
    func onClosePressed() {
        self.dismiss(animated: true)
    }
    
    func onAddPlayerPressed(with fields: EditPlayerFields?) {
        if let fields = fields {
            let athlete = Athlete.create(from: fields)
            let _ = DatabaseUtil.insert(doc: athlete)
            self.dismiss(animated: true)
        }
    }
}

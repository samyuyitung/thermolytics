//
//  NameSessionModalViewController.swift
//  Thermolytic
//
//  Created by Sam Yuyitung on 2020-02-25.
//  Copyright © 2020 Sam Yuyitung. All rights reserved.
//

import UIKit

class NameSessionModalViewController: UIViewController {
    
    @IBAction func backgroundPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func closePressed(_ sender: Any) {
        self.dismiss(animated: true)
    }

    @IBOutlet weak var textField: UITextField!
    
    @IBAction func startSessionPressed(_ sender: Any) {
        if let name = textField.validateString() {
            RecordingSessionManager.shared.startSession(named: name)
            self.dismiss(animated: true)
        }
    }
}

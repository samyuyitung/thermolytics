//
//  CreateNewUserViewController.swift
//  Thermolytic
//
//  Created by Sam Yuyitung on 2020-01-27.
//  Copyright © 2020 Sam Yuyitung. All rights reserved.
//

import UIKit
import CouchbaseLiteSwift

class CreateNewUserViewController : UIViewController {
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return true
    }
    
}

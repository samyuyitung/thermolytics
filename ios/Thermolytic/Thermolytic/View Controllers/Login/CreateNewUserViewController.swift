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
        return isValid()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        App.user = User.getUserBy(username: usernameField.text!)
    }
    
    
    func isValid() -> Bool {
        let username = usernameField.validateString()
        let password = passwordField.validateString()
        let confirmPassword = confirmPasswordField.validateString()
        
        if password != confirmPassword {
            confirmPasswordField.setError()
            return false
        }
        
        if let username = username, let password = password {
            if let _ = User.getUserBy(username: username) {
                Utils.log(at: .Warning, msg: "Tried to add existing user \(username)")
                usernameField.setError()
                return false
            }
            let userDoc = User.create(username: username, rawPassword: password)
            return DatabaseUtil.insert(doc: userDoc)
        }
        return false
    }
    
}

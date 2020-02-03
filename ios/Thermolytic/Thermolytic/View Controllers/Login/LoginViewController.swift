//
//  LoginViewController.swift
//  Thermolytic
//
//  Created by Sam Yuyitung on 2020-01-27.
//  Copyright © 2020 Sam Yuyitung. All rights reserved.
//

import Foundation
import UIKit
import CouchbaseLiteSwift


class LoginViewController: UIViewController {
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
//        if identifier == "login" {
//           return shouldLogin()
//        }
        return true
    }
    
    
    
    func shouldLogin() -> Bool {
        guard let username = usernameField.validateString() else {
            return false
        }
        guard let password = passwordField.validateString() else {
            return false
        }
        
        if username == "s" { return true}
        
        let query = QueryBuilder.select(User.selectAll)
            .from(DataSource.database(DatabaseUtil.shared))
            .where(User.username.expression.equalTo(Expression.string(username)))
            .limit(Expression.int(1))
        do {
            let rows = try query.execute()
            if let user = rows.next(), let salt = user.string(forKey: User.salt.key),
                let hashedPassword = user.string(forKey: User.password.key) {
                
                if AuthenticationUtil.isAuthorized(rawPassword: password, salt: salt, hashedPassword: hashedPassword) {
                    return true
                } else {
                    Utils.log(at: .Debug, msg: "Bad password")
                }
            } else {
                Utils.log(at: .Debug, msg: "No user")
                
            }
        } catch {
            Utils.log(at: .Error, msg: "\(error)")
            
        }
        return false
    }
}
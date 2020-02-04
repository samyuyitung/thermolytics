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
    @IBOutlet weak var teamField: UITextField!
    @IBOutlet weak var roleField: UITextField!
    
    lazy var rolePicker: UIPickerView = {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        
        return picker
    }()
    
    override func viewDidLoad() {
        roleField.inputView = rolePicker
    }
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return isValid()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        do {
            App.user = User.getUserBy(username: usernameField.text!)
            App.shared = try DatabaseUtil.openDatabase(name: App.user!.string(forKey: User.team.key)!)
        } catch {
            Utils.log(at: .Error, msg: "\(error)")
        }
    }
    
    private struct Fields {
        var username = ""
        var password = ""
        var confirmPassword = ""
        var team = ""
        var role: User.Role = .player
    }
    
    func isValid() -> Bool {
        var hasError = false
        var fields = Fields()
        
        if let username = usernameField.validateString() {
            fields.username = username
        } else {
            hasError = true
        }
        if let password = passwordField.validateString() {
            fields.password = password
        } else {
            hasError = true
        }
        if let confirmPassword = confirmPasswordField.validateString() {
            fields.confirmPassword = confirmPassword
        } else {
            hasError = true
        }
        if let team = teamField.validateString() {
            fields.team = team
        } else {
            hasError = true
        }
        if let roleStr = roleField.validateString(), let role = User.Role(rawValue: roleStr) {
            fields.role = role
        } else {
            hasError = true
        }
        
        if fields.password != fields.confirmPassword {
            confirmPasswordField.setError()
            hasError = true
        }
        
        if let _ = User.getUserBy(username: fields.username) {
            Utils.log(at: .Warning, msg: "Tried to add existing user \(fields.username)")
            usernameField.setError()
            hasError = true
        }
        
        guard !hasError else {
            return false
        }
        
        let userDoc = User.create(username: fields.username, rawPassword: fields.password, team: fields.team, role: fields.role)
        return DatabaseUtil.insert(doc: userDoc, into: App.userDB)
    }
}

extension CreateNewUserViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return User.Role.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return User.Role.allCases[row].rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        roleField.text = User.Role.allCases[row].rawValue
    }
}

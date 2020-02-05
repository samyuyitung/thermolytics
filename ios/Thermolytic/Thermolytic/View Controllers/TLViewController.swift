//
//  TLViewController.swift
//  Thermolytic
//
//  Created by Sam Yuyitung on 2020-02-04.
//  Copyright © 2020 Sam Yuyitung. All rights reserved.
//

import UIKit

struct Permissioned {
    enum Effect {
        case hide
        case disable // Assumed UIButton
    }
    
    var view: UIView
    var effect: Permissioned.Effect
    var minLevel: User.Role
}

class TLViewController: UIViewController {
    var permissions: [Permissioned] = []
    
    func applyPermissions() {
        for permission in permissions {
            if let role = User.Role(rawValue: App.user?.string(forKey: User.role.key) ?? "") {
                if role.isAtLeast(role: permission.minLevel) {
                    continue
                }
                switch permission.effect {
                case .hide:
                    permission.view.isHidden = true
                case .disable:
                    (permission.view as! UIButton).isEnabled = false
                    permission.view.alpha = 0.3
                
                }
            }
        }
    }
    
    override func viewDidLoad() {
        applyPermissions()
    }
}

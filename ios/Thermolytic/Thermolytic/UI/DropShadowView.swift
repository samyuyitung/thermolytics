//
//  DropShadowView.swift
//  Thermolytic
//
//  Created by Sam Yuyitung on 2020-01-19.
//  Copyright © 2020 Sam Yuyitung. All rights reserved.
//

import UIKit

class DropShadowView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        didLoad()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        didLoad()
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    func didLoad() {
        self.addShadow()
    }
    
}

extension UIView {
    func addShadow() {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.25
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.layer.shadowRadius = 8
    }
}

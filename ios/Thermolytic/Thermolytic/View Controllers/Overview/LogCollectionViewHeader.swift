//
//  LogCollectionViewHeader.swift
//  Thermolytic
//
//  Created by Sam Yuyitung on 2020-02-26.
//  Copyright © 2020 Sam Yuyitung. All rights reserved.
//

import UIKit

class LogCollectionViewHeader: UICollectionReusableView {
    
    @IBOutlet weak var title: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
}


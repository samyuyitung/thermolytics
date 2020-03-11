//
//  LogItemCell.swift
//  Thermolytic
//
//  Created by Sam Yuyitung on 2019-11-20.
//  Copyright © 2019 Sam Yuyitung. All rights reserved.
//


import UIKit
import CouchbaseLiteSwift


protocol LogItemCellDelegate {
    func didPressDetail(for cell: LogItemCell)
}

class LogItemCell: UICollectionViewCell {
    
    static let height = 170
    static let portraitWidthRatio = 2.0
    static let landscapeWidthRatio = 4.0
    
    @IBOutlet weak var borderCircle: UIView!
    @IBOutlet weak var tempImage: UIImageView!
    @IBOutlet weak var heartRateImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var number: UILabel!
    @IBOutlet weak var heartRate: UILabel!
    @IBOutlet weak var temperature: UILabel!
    @IBAction func didPressDetail(_ sender: Any) {
        delegate?.didPressDetail(for: self)
    }
    
    var uid: String? = nil
    var delegate: LogItemCellDelegate? = nil
        
    func configure(user: Result, frame: Result?, onBench: Bool) {
        
        layer.backgroundColor = UIColor.clear.cgColor
        layer.cornerRadius = 8
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 3
        layer.masksToBounds = false

        borderCircle.layer.cornerRadius =  (borderCircle.frame.width / 2)
        borderCircle.layer.masksToBounds = true
        
        if onBench {
            self.backgroundColor = UIColor(white: 0.92, alpha: 1)
        } else {
            self.backgroundColor = UIColor(white: 1, alpha: 1)
        }
        
        uid = user.getId()

        tempImage.tintColor = .black
        heartRateImage.tintColor = .black
        borderCircle.backgroundColor = .clear

        
        self.number.text = "#\(user.int(forKey: Athlete.number.key))"
        self.name.text = "\(user.string(forKey: Athlete.name.key) ?? "")"
        
        if let frame = frame {
            let hr = frame.int(forKey: BioFrame.heartRate.key)
            let temp = frame.float(forKey: BioFrame.predictedCoreTemp.key)
            
            self.heartRate.text = "\(hr)"
            self.temperature.text = "\(temp.print(to: 1))℃"
        
            let thresholdTemp = user.float(forKey: Athlete.thresholdTemp.key)
            if temp > thresholdTemp {
                self.backgroundColor = UIColor(r: 255, g: 197, b: 197)
                tempImage.tintColor = .red
                heartRateImage.tintColor = .red
            } else if temp > thresholdTemp - 0.5 {
                let yellow = UIColor(r: 255, g: 199, b: 0)
                tempImage.tintColor = yellow
                heartRateImage.tintColor = yellow
            } else {
                tempImage.tintColor = .black
                heartRateImage.tintColor = .black
                borderCircle.backgroundColor = .clear
            }
        }
    }
}


extension UIColor {
    convenience init(r: Int, g: Int, b: Int, a: Int = 255) {
        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(a) / 255.0)
    }
}

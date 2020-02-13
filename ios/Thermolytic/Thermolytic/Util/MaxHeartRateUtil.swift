//
//  MaxHeartRateUtil.swift
//  Thermolytic
//
//  Created by Sam Yuyitung on 2020-02-03.
//  Copyright © 2020 Sam Yuyitung. All rights reserved.
//

import Foundation

class HeartRateUtil {
    static func getMaxHeartRate(age: Int) -> Int {
        if age < 20 { return 200 }
        return 200 - ((age - 20) / 5) * 5
    }
    
    static  func getPercentHeartRate(hr: Int, age: Int) -> Double {
        return Double(hr) / Double(getMaxHeartRate(age: age))
    }
}

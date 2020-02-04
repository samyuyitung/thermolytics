//
//  MaxHeartRateUtil.swift
//  Thermolytic
//
//  Created by Sam Yuyitung on 2020-02-03.
//  Copyright © 2020 Sam Yuyitung. All rights reserved.
//

import Foundation

class AA {
    func getMaxHeartRate(age: Int) -> Int {
        if age < 20 { return 200 }
        return 200 - ((age - 20) / 5) * 5
    }
    
    func getPercentHeartRate(hr: Int, age: Int) -> Double {
        return Double(hr) / Double(getMaxHeartRate(age: age))
    }
}
/*
 (age - 20) / 5
 
 20 years    200 bpm
 30 years    190 bpm
 35 years    185 bpm
 40 years    180 bpm
 45 years    175 bpm
 50 years    170 bpm
 55 years    165 bpm
 60 years    160 bpm
 65 years    155 bpm
 70 years    150 bpm
 */

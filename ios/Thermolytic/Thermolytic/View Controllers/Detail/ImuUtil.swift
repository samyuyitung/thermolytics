//
//  ImuUtil.swift
//  Thermolytic
//
//  Created by Sam Yuyitung on 2020-03-10.
//  Copyright © 2020 Sam Yuyitung. All rights reserved.
//

import Foundation

struct Point {
    var x: Double
    var y: Double
    
    func magnitude(x: Double, y: Double) -> Double {
        return sqrt(x*x + y*y)
    }
}

class ImuUtil {
    
    static func getVelocity(v: Point = Point(x: 0, y: 0), a: Point, dt: TimeInterval) -> Point {
        return Point(x: v.x + a.x * dt, y: v.y + a.y * dt)
    }
}

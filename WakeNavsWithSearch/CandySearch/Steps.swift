//
//  Steps.swift
//  WakeNavs
//
//  Created by Kevin Lin on 4/25/16.
//  Copyright © 2016 Kevin Lin. All rights reserved.
//

import Foundation
import CoreLocation

class Steps {
    var duration: Int = 0
    var distance: Int = 0
    var coordinates: CLLocationCoordinate2D
    var encodedPoly: String
    var instructions: String = ""
    
    init(dur: Int, dist: Int, coor: CLLocationCoordinate2D, poly: String, inst: String) {
        self.duration = dur
        self.distance = dist
        self.coordinates = coor
        self.encodedPoly = poly
        self.instructions = inst
    }
}
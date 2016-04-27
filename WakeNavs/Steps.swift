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
    var coordinates: CLLocationCoordinate2D
    var encodedPoly: String
    var instructions: String = ""
    
    init(coor: CLLocationCoordinate2D, poly: String, inst: String) {        self.coordinates = coor
        self.encodedPoly = poly
        self.instructions = inst
    }
}
//
//  Route.swift
//  Map Tracker
//
//  Created by Jad Charbatji on 3/22/23.
//

import Foundation
import CoreLocation

struct Route: Identifiable {
    let id = UUID()
    var coordinates: [CLLocation]
    var distance: CLLocationDistance
    var duration: TimeInterval
    var timestamp: Date
}

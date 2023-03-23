//
//  CodableCLLocation.swift
//  Map Tracker
//
//  Created by Jad Charbatji on 3/23/23.
//

// CodableCLLocation.swift

import Foundation
import CoreLocation

struct CodableCLLocation: Codable {
    let latitude: Double
    let longitude: Double
    let timestamp: Date
}

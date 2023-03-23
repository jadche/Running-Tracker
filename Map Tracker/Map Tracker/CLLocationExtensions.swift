//
//  CLLocationExtensions.swift
//  Map Tracker
//
//  Created by Jad Charbatji on 3/23/23.
//

// CLLocationExtensions.swift

import Foundation
import CoreLocation

extension CLLocation {
    func toCodableCLLocation() -> CodableCLLocation {
        return CodableCLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude, timestamp: timestamp)
    }
    
    convenience init(coordinate: Coordinate) {
        self.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}

extension CodableCLLocation {
    func toCLLocation() -> CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
}

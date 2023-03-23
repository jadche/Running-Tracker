//
//  Route.swift
//  Map Tracker
//
//  Created by Jad Charbatji on 3/22/23.
//

import Foundation
import CoreLocation
import Firebase
import FirebaseFirestoreSwift
//
//struct Route: Identifiable {
//    let id = UUID()
//    var coordinates: [CLLocation]
//    var distance: CLLocationDistance
//    var duration: TimeInterval
//    var timestamp: Date
//}

//edited for firebase storage
//struct Coordinate: Codable {
//    var latitude: Double
//    var longitude: Double
//
//    init(latitude: Double, longitude: Double) {
//        self.latitude = latitude
//        self.longitude = longitude
//    }
//
//    init(from location: CLLocation) {
//        self.latitude = location.coordinate.latitude
//        self.longitude = location.coordinate.longitude
//    }
//
//    func toCLLocation() -> CLLocation {
//        return CLLocation(latitude: latitude, longitude: longitude)
//    }
//}
//
//struct Route: Identifiable, Codable {
//    let id: UUID
//    var coordinates: [Coordinate]
//    var distance: CLLocationDistance
//    var duration: TimeInterval
//    var timestamp: Date
//
//    init(id: UUID = UUID(), coordinates: [Coordinate], distance: CLLocationDistance, duration: TimeInterval, timestamp: Date) {
//        self.id = id
//        self.coordinates = coordinates
//        self.distance = distance
//        self.duration = duration
//        self.timestamp = timestamp
//    }
//}

//fixing fetched data
struct Coordinate: Codable, Equatable {
    var latitude: Double
    var longitude: Double

}

extension Coordinate {
    init(from location: CLLocation) {
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
    }
}


struct Route: Identifiable, Codable {
    let id: UUID
    var coordinates: [Coordinate]
    var distance: CLLocationDistance
    var duration: TimeInterval
    var timestamp: Date

    init(id: UUID = UUID(), coordinates: [Coordinate], distance: CLLocationDistance, duration: TimeInterval, timestamp: Date) {
        self.id = id
        self.coordinates = coordinates
        self.distance = distance
        self.duration = duration
        self.timestamp = timestamp
    }
}


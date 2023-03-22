//
//  TrackerViewModel.swift
//  Map Tracker
//
//  Created by Jad Charbatji on 3/22/23.
//

import SwiftUI
import Foundation
import Combine
import CoreLocation


class TrackerViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var tracking: Bool = false
    @Published var currentLocation: CLLocation?
    @Published var routes: [Route] = []
    private var currentRoute: Route?
    
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .fitness
        locationManager.allowsBackgroundLocationUpdates = true
    }
    
    func startTracking() {
        locationManager.requestWhenInUseAuthorization()
        currentRoute = Route(coordinates: [], distance: 0, duration: 0)
        locationManager.startUpdatingLocation()
    }
    
    func stopTracking() {
        locationManager.stopUpdatingLocation()
        if let route = currentRoute {
            let statistics = calculateStatistics(for: route)
            routes.append(Route(coordinates: route.coordinates, distance: statistics.distance, duration: statistics.duration))
            currentRoute = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocation = location
            
            if tracking {
                currentRoute?.coordinates.append(location)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            if tracking {
                startTracking()
            }
        default:
            break
        }
    }
    func calculateStatistics(for route: Route) -> (distance: CLLocationDistance, duration: TimeInterval) {
        let distance = route.coordinates.reduce(CLLocationDistance(0)) { result, location in
            let previousLocationIndex = route.coordinates.firstIndex(of: location)! - 1
            guard previousLocationIndex >= 0 else { return result }
            let previousLocation = route.coordinates[previousLocationIndex]
            return result + location.distance(from: previousLocation)
        }

        let duration = route.coordinates.last?.timestamp.timeIntervalSince(route.coordinates.first!.timestamp) ?? 0

        return (distance, duration)
    }

}

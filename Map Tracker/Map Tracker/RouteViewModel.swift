//
//  RouteViewModel.swift
//  Map Tracker
//
//  Created by Faisal Atif on 2023-03-21.
//

import Foundation
import CoreLocation

class RouteViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    // stores the route's coordinates as an array of CLLocationCoordinate2D
    // This will get updated as the user moves
    @Published var route: [CLLocationCoordinate2D] = []
    // Keeps track of the tracking state
    @Published var tracking = false
    // Stores the CLLcationManager instance, which is responsible for managing location updates
    private var locationManager: CLLocationManager

    // The initializer takes a CLLocationManager instance as a parameter, assigns it to the locationManager property, and sets the delegate to self
    init(locationManager: CLLocationManager) {
        self.locationManager = locationManager
        super.init()
        self.locationManager.delegate = self
    }

    // This method is part of the CLLocationManagerDelegate protocol. It's called when the location manager receives new location updates.
    // If tracking is true, the method appends the new location's coordinates to the route array
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard tracking, let location = locations.last else { return }
        route.append(location.coordinate)
    }
}

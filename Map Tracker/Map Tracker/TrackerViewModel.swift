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
import CoreData
import FirebaseFirestore
import FirebaseAuth


class TrackerViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var tracking: Bool = false
    @Published var currentLocation: CLLocation?
    @Published var routes: [Route] = []
    private var currentRoute: Route?
    private var trackingStartTime: Date?
    private let firebaseManager = FirebaseManager()
    private let db = Firestore.firestore()
//    @objc func saveRoutesBeforeTerminate() {
//        saveRoutesToFirestore()
//    }
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .fitness
        locationManager.allowsBackgroundLocationUpdates = true
        loadRoutes()
//        NotificationCenter.default.addObserver(self, selector: #selector(saveRoutesBeforeTerminate), name: UIApplication.willTerminateNotification, object: nil)

    }
    
    func startTracking() {
        print("startTracking() function called")
        locationManager.requestWhenInUseAuthorization()
        currentRoute = Route(coordinates: [], distance: 0, duration: 0, timestamp: Date())
        trackingStartTime = Date()
        locationManager.startUpdatingLocation()
    }
    
    // added always location
//    func startTracking() {
//        locationManager.requestWhenInUseAuthorization()
//
//        if CLLocationManager.authorizationStatus() == .authorizedAlways {
//            locationManager.startUpdatingLocation()
//            currentRoute = Route(coordinates: [], distance: 0, duration: 0, timestamp: Date())
//            trackingStartTime = Date()
//            tracking = true
//        } else {
//            locationManager.requestAlwaysAuthorization()
//        }
//    }

    func stopTracking() {
        locationManager.stopUpdatingLocation()
        if let route = currentRoute, let startTime = trackingStartTime {
            let statistics = calculateStatistics(for: route)
            let duration = Date().timeIntervalSince(startTime)
            let newRoute = Route(coordinates: route.coordinates, distance: statistics.distance, duration: duration, timestamp: Date())
            routes.append(newRoute)
//      save to firestore
            firebaseManager.saveRouteToFirestore(route: newRoute) { result in
                        switch result {
                        case .success:
                            print("Route added successfully")
                        case .failure(let error):
                            print("Error adding route: \(error)")
                        }
                    }
            print("Routessss", routes)
//            saveRoute(newRoute)
            currentRoute = nil
            trackingStartTime = nil
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
    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        if let location = locations.last {
//            currentLocation = location
//           // print("User's location: \(location)")
//
//            if tracking {
//                currentRoute?.coordinates.append(location.toCodableCLLocation())
//            }
//        }
//    }
    
//  new route struct location manager
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocation = location

            if tracking {
                let coordinate = Coordinate(from: location)
                currentRoute?.coordinates.append(coordinate)
            }
        }
    }

//    func calculateStatistics(for route: Route) -> (distance: CLLocationDistance, duration: TimeInterval) {
//        let distance = zip(route.coordinates, route.coordinates.dropFirst()).reduce(0) { result, pair in
//            let (location1, location2) = pair
//            return result + location1.distance(from: location2)
//        }
//
//        let duration = route.coordinates.last?.timestamp.timeIntervalSince(route.coordinates.first!.timestamp) ?? 0
//
//        return (distance, duration)
//    }
    
    
//  converting coordinates before calculating stats
    func calculateStatistics(for route: Route) -> (distance: CLLocationDistance, duration: TimeInterval) {
        let locations = route.coordinates.map { CLLocation(latitude: $0.latitude, longitude: $0.longitude) }

        let distance = zip(locations, locations.dropFirst()).reduce(0) { result, pair in
            let (location1, location2) = pair
            return result + location1.distance(from: location2)
        }

        let duration = route.timestamp.timeIntervalSince(route.timestamp)

        return (distance, duration)
    }
    
    func loadRoutes() {
        guard let user = Auth.auth().currentUser else {
            print("User not signed in")
            return
        }

        print("Signed in user ID: \(user.uid)")

        firebaseManager.fetchRoutes { result in
            switch result {
            case .success(let routes):
                DispatchQueue.main.async {
                    self.routes = routes
                    print("Fetched routes: \(routes)")
                }
            case .failure(let error):
                print("Error loading routes: \(error)")
            }
        }
    }


    //'saveRoutesToFirestore' method here iterates through the recorded routes and calls the 'saveRouteToFirestore' method of the 'FirebaseManager' to save each one to the database.
    
    func saveRoutesToFirestore() {
        for route in routes {
            firebaseManager.saveRouteToFirestore(route: route) { result in
                switch result {
                case .success:
                    print("Route added successfully")
                case .failure(let error):
                    print("Error adding route: \(error)")
                }
            }
        }
    }
}

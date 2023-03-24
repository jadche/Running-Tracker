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
    private let firebaseManager = FirebaseManager()
    private let db = Firestore.firestore()
    
    //Changed it to a public variable to be able to access it from ContentView
    @Published var trackingStartTime: Date?
    // To keep track of the timer every second for the main page
    // Needed since the route duration is not calculated in real time
    @Published var elapsedTime: TimeInterval = 0
    private var timer: Timer?

    
    // Improve Accuracy 3 - Calculate moving average
    let movingAverageWindowSize = 5
    var recentLocations: [CLLocation] = []
    
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        //Improve acuracy - 1 set best accuracy
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .fitness
        locationManager.allowsBackgroundLocationUpdates = true
        loadRoutes()
    }
    
    func startTracking() {
        print("startTracking() function called")
        locationManager.requestWhenInUseAuthorization()
        currentRoute = Route(coordinates: [], distance: 0, duration: 0, timestamp: Date())
        trackingStartTime = Date()
        locationManager.startUpdatingLocation()
        
        // Start the timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if let startTime = self.trackingStartTime {
                self.elapsedTime = Date().timeIntervalSince(startTime)
            }
        }
        
    }

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
        // Stop the timer and reset elapsedTime
        timer?.invalidate()
        timer = nil
        elapsedTime = 0
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
    
//  new route struct location manager
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocation = location
            
//            if tracking {
//                let coordinate = Coordinate(from: location)
//                currentRoute?.coordinates.append(coordinate)
//            }
            // Improve Accuracy 2 - Discard locations with an accuracy worse than 20 meters
            guard let location = locations.last, location.horizontalAccuracy <= 20 else { return }
            
            // Improve Accuracy 3 - Uses the calculated moving average instead of the raw data
            // Data passes by a 'averageLocation' function first
            recentLocations.append(location)
            if recentLocations.count > movingAverageWindowSize {
                recentLocations.removeFirst()
            }
            
            let smoothedLocation = averageLocation(recentLocations)
            
            // Update the route with the smoothed location
            if tracking {
            currentRoute?.coordinates.append(Coordinate(from: smoothedLocation))
            }
        }
    }
        
        // Improve Accuracy 3 - calculating moving average for the location for smoothing
    func averageLocation(_ locations: [CLLocation]) -> CLLocation {
        let totalLatitude = locations.reduce(0) { $0 + $1.coordinate.latitude }
        let totalLongitude = locations.reduce(0) { $0 + $1.coordinate.longitude }
        
        let averageLatitude = totalLatitude / Double(locations.count)
        let averageLongitude = totalLongitude / Double(locations.count)
        
        return CLLocation(latitude: averageLatitude, longitude: averageLongitude)
    }
    
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
        // Change seconds into a human readble form with hours or minutes when needed
    func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }

//  'saveRoutesToFirestore' method here iterates through the recorded routes and calls the 'saveRouteToFirestore' method of the 'FirebaseManager' to save each one to the database.
        
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

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


class TrackerViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var tracking: Bool = false
    @Published var currentLocation: CLLocation?
    @Published var routes: [Route] = []
    private var currentRoute: Route?
    private var trackingStartTime: Date?
    
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .fitness
        locationManager.allowsBackgroundLocationUpdates = true
//        loadRoutes()
    }
    
    func startTracking() {
        locationManager.requestWhenInUseAuthorization()
        currentRoute = Route(coordinates: [], distance: 0, duration: 0, timestamp: Date())
        trackingStartTime = Date()
        locationManager.startUpdatingLocation()
    }
    
    func stopTracking() {
        locationManager.stopUpdatingLocation()
        if let route = currentRoute, let startTime = trackingStartTime {
            let statistics = calculateStatistics(for: route)
            let duration = Date().timeIntervalSince(startTime)
            let newRoute = Route(coordinates: route.coordinates, distance: statistics.distance, duration: duration, timestamp: Date())
            routes.append(newRoute)
//            saveRoute(newRoute)
            currentRoute = nil
            trackingStartTime = nil
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
        let distance = zip(route.coordinates, route.coordinates.dropFirst()).reduce(0) { result, pair in
            let (location1, location2) = pair
            return result + location1.distance(from: location2)
        }
        
        let duration = route.coordinates.last?.timestamp.timeIntervalSince(route.coordinates.first!.timestamp) ?? 0
        
        return (distance, duration)
    }
    func generateMockData() -> [CLLocation] {
        let coordinates = [
            CLLocationCoordinate2D(latitude: 37.74, longitude: 32.3),
            CLLocationCoordinate2D(latitude: 37.73, longitude: 32.4)
        ]
        let timestamp = Date()
        return coordinates.map { CLLocation(coordinate: $0, altitude: 0, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: timestamp) }
    }
    
//    func saveRoute(_ route: Route) {
//        let routeEntity = RouteEntity(context: CoreDataManager.shared.context)
//        routeEntity.coordinatesData = try? NSKeyedArchiver.archivedData(withRootObject: route.coordinates, requiringSecureCoding: false)
//        routeEntity.distance = route.distance
//        routeEntity.duration = route.duration
//        routeEntity.timestamp = route.timestamp
//        CoreDataManager.shared.saveContext()
//    }
//
//    func loadRoutes() {
//        let fetchRequest: NSFetchRequest<RouteEntity> = RouteEntity.fetchRequest()
//
//        do {
//            let routeEntities = try CoreDataManager.shared.context.fetch(fetchRequest)
//            routes = routeEntities.compactMap { routeEntity in
//                guard let coordinatesData = routeEntity.coordinatesData,
//                      let coordinates = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(coordinatesData) as? [CLLocation] else {
//                    return nil
//                }
//                return Route(coordinates: coordinates, distance: routeEntity.distance, duration: routeEntity.duration, timestamp: routeEntity.timestamp)
//            }
//
//        } catch {
//            print("Error loading routes: \(error)")
//        }
//    }
}

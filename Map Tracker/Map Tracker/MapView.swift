//
//  MapView.swift
//  Map Tracker
//
//  Created by Faisal Atif on 2023-03-21.
//

import SwiftUI
import MapKit
import CoreLocation

//struct MapView: UIViewRepresentable {
//    var route: [CLLocationCoordinate2D]
//
//    //Creates an instance of 'MKMapView', sets its delegate to the coordinator and returns it.
//    func makeUIView(context: Context) -> MKMapView {
//        let mapView = MKMapView()
//        mapView.delegate = context.coordinator
//        return mapView
//    }
//
//    // Updates the map view when the route binding changes
//    // It removes all existing overlays, creates a new polyline with the route's coordinates, and adds it as an overlay to the map view.
//    func updateUIView(_ uiView: MKMapView, context: Context) {
//        uiView.removeOverlays(uiView.overlays)
//        let polyline = MKPolyline(coordinates: route, count: route.count)
//        uiView.addOverlay(polyline)
//
//        // Zoom and center the map on the actual route
//        let mapRect = polyline.boundingMapRect
//        let edgePadding = UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50)
//        uiView.setVisibleMapRect(mapRect, edgePadding: edgePadding, animated: true)
//    }
//
//
//    // Creates an instance of the coordinator class and returns it
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    // The Coordinator class is used to customize the appearance of the overlay.
//    class Coordinator: NSObject, MKMapViewDelegate {
//        var parent: MapView
//
//        init(_ parent: MapView) {
//            self.parent = parent
//        }
//
//        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
//            if let polyline = overlay as? MKPolyline {
//                let renderer = MKPolylineRenderer(polyline: polyline)
//                //Set stoke color and line width
//                renderer.strokeColor = UIColor.red
//                renderer.lineWidth = 4
//                return renderer
//            }
//            return MKOverlayRenderer(overlay: overlay)
//        }
//    }
//}

//struct MapView: UIViewRepresentable {
//    var route: [CLLocationCoordinate2D]
//
//    //Creates an instance of 'MKMapView', sets its delegate to the coordinator and returns it.
//    func makeUIView(context: Context) -> MKMapView {
//        let mapView = MKMapView()
//        mapView.showsUserLocation = true // Enable showing user's current location
//        mapView.delegate = context.coordinator
//
//        // Set a fixed region to display
//        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), latitudinalMeters: 500, longitudinalMeters: 500)
//        mapView.setRegion(region, animated: false)
//
//        return mapView
//    }
//
//    // Updates the map view when the route binding changes
//    // It removes all existing overlays, creates a new polyline with the route's coordinates, and adds it as an overlay to the map view.
//    func updateUIView(_ uiView: MKMapView, context: Context) {
//        uiView.removeOverlays(uiView.overlays)
//        let polyline = MKPolyline(coordinates: route, count: route.count)
//        uiView.addOverlay(polyline)
//    }
//
//    // Creates an instance of the coordinator class and returns it
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    // The Coordinator class is used to customize the appearance of the overlay.
//    class Coordinator: NSObject, MKMapViewDelegate {
//        var parent: MapView
//
//        init(_ parent: MapView) {
//            self.parent = parent
//        }
//
//        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
//            if let polyline = overlay as? MKPolyline {
//                let renderer = MKPolylineRenderer(polyline: polyline)
//                //Set stoke color and line width
//                renderer.strokeColor = UIColor.red
//                renderer.lineWidth = 4
//                return renderer
//            }
//            return MKOverlayRenderer(overlay: overlay)
//        }
//    }
//}

//adding markers

struct MapView: UIViewRepresentable {
    var route: [CLLocationCoordinate2D]

    // Creates an instance of 'MKMapView', sets its delegate to the coordinator and returns it.
    
    //replacement bellow
//    func makeUIView(context: Context) -> MKMapView {
//        let mapView = MKMapView()
//        mapView.showsUserLocation = true
//        mapView.delegate = context.coordinator
//        // To do change the coor from hard cooded to user's location
//        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 70.7749, longitude: -81.4194), latitudinalMeters: 500, longitudinalMeters: 500)
//        mapView.setRegion(region, animated: false)
//        return mapView
//    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.showsUserLocation = true
        mapView.delegate = context.coordinator

        // Center the map view on the user's location once it becomes available
        if let userLocation = mapView.userLocation.location {
            let region = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
            mapView.setRegion(region, animated: false)
            print(userLocation.coordinate)
        }

        return mapView
    }

    // Updates the map view when the route binding changes
    // It removes all existing overlays and annotations, creates a new polyline with the route's coordinates, and adds it as an overlay to the map view.
    //Creates the marker
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeOverlays(uiView.overlays)
        uiView.removeAnnotations(uiView.annotations)

        let polyline = MKPolyline(coordinates: route, count: route.count)
        uiView.addOverlay(polyline)

        // Add start and end markers
        if let startLocation = route.first {
            let startMarker = MKPointAnnotation()
            startMarker.coordinate = startLocation
            startMarker.title = "Start"
            uiView.addAnnotation(startMarker)
        }

        if let endLocation = route.last {
            let endMarker = MKPointAnnotation()
            endMarker.coordinate = endLocation
            endMarker.title = "End"
            uiView.addAnnotation(endMarker)
        }
    }

    // Creates an instance of the coordinator class and returns it
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // The Coordinator class is used to customize the appearance of the overlay.
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = UIColor.red
                renderer.lineWidth = 4
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }

//        // Customize the appearance of the annotation views
//        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//            if annotation is MKUserLocation {
//                // Use the default blue dot for the user's current location
//                return nil
//            }
//
//            let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
//            annotationView.pinTintColor = UIColor.blue
//            annotationView.canShowCallout = true
//            return annotationView
       // }
    }
}


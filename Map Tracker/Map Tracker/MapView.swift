//
//  MapView.swift
//  Map Tracker
//
//  Created by Faisal Atif on 2023-03-21.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    var route: [CLLocationCoordinate2D]

    //Creates an instance of 'MKMapView', sets its delegate to the coordinator and returns it.
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }

    // Updates the map view when the route binding changes
    // It removes all existing overlays, creates a new polyline with the route's coordinates, and adds it as an overlay to the map view.
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeOverlays(uiView.overlays)
        let polyline = MKPolyline(coordinates: route, count: route.count)
        uiView.addOverlay(polyline)
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
                //Set stoke color and line width
                renderer.strokeColor = UIColor.red
                renderer.lineWidth = 4
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}

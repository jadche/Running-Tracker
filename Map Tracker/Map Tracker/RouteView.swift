//
//  RouteView.swift
//  Map Tracker
//
//  Created by Jad Charbatji on 3/22/23.
//

// Individual components on the lists on the second page

import Foundation
import SwiftUI
import Combine
import CoreLocation

// convert coordinates
struct RouteView: View {
    let route: Route

    var body: some View {
        VStack {
            MapView(route: route.coordinates.map { CLLocation(coordinate: $0).coordinate })
            Text("Distance: \(String(format: "%.2f", route.distance)) meters")
            Text("Duration: \(String(format: "%.2f", route.duration)) seconds")
        }
    }
}


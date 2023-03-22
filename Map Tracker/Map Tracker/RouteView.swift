//
//  RouteView.swift
//  Map Tracker
//
//  Created by Jad Charbatji on 3/22/23.
//

import Foundation
import SwiftUI
import Combine

struct RouteView: View {
    let route: Route

    var body: some View {
        VStack {
            MapView(coordinates: route.coordinates)
            Text("Distance: \(String(format: "%.2f", route.distance)) meters")
            Text("Duration: \(String(format: "%.2f", route.duration)) seconds")
        }
    }
}

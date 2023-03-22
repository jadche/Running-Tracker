//
//  RouteListView.swift
//  Map Tracker
//
//  Created by Jad Charbatji on 3/22/23.
//

import SwiftUI
import Combine
import Foundation

struct RouteListView: View {
    @ObservedObject var trackerViewModel: TrackerViewModel

    var body: some View {
        List(trackerViewModel.routes) { route in
            NavigationLink(destination: RouteView(route: route)) {
                VStack(alignment: .leading) {
                    Text("Distance: \(route.distance, specifier: "%.2f") meters")
                    Text("Duration: \(route.duration, specifier: "%.2f") seconds")
                }
            }
        }
    }
}

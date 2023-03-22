//
//  ContentView.swift
//  Map Tracker
//
//  Created by Faisal Atif on 2023-03-21.
//
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TrackerViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.tracking {
                    Color.red
                } else {
                    Color.green
                }

                Button(action: {
                    viewModel.tracking.toggle()
                    if viewModel.tracking {
                        viewModel.startTracking()
                    } else {
                        viewModel.stopTracking()
                    }
                }) {
                    VStack {
                        if viewModel.tracking {
                            Text("Stop Tracking")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                        } else {
                            Text("Start Tracking")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)
            .navigationTitle("Map Tracker")
            .navigationBarItems(trailing: NavigationLink(destination: RouteListView(trackerViewModel: viewModel)) {
                Text("View Past Routes")
            })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TrackerViewModel()

    var body: some View {
        ZStack {
            if viewModel.tracking {
                Color.red
            } else {
                Color.green
            }
            
            Button(action: {
                viewModel.tracking.toggle()
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
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//
//  ContentView.swift
//  RescueApp
//
//  Created by Saishreeya Kantamsetty on 11/2/24.
//

import SwiftUI

enum LoadingState {
    case loading
    case working
}

struct ContentView: View {
    @StateObject var bluetoothManager = BluetoothManager()
    @StateObject private var locationManager = LocationManager()
    @State private var progress: Double = 0.0
    @State private var state: LoadingState = .loading
    
    var body: some View {
        if state == .loading {
            LoadingView(progress: $progress)
                .onAppear {
                    startLoading()
                }
        } else {
            MapView(bluetoothManager: bluetoothManager, locationManager: locationManager)
        }
    }
       
    
    func startLoading() {
        // Simulate loading progress over 3 seconds
        Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { timer in
            if self.progress < 100 {
                self.progress += 1
            } else {
                timer.invalidate()
                state = .working
            }
        }
    }
}

#Preview {
    ContentView()
}

//
//  MapView.swift
//  RescueApp
//
//  Created by Alexandra Marum on 11/2/24.
//

import MapKit
import SwiftData
import SwiftUI

struct MapView: View {
    // bluetooth and network
    @ObservedObject private var networkMonitor = NetworkMonitor()
    @ObservedObject private var bluetoothManager = BluetoothManager()
    
    // location
    @StateObject var locationManager = LocationManager()
    @State private var region: MKCoordinateRegion = .init(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // Default to San Francisco
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    // local storage
    @Environment(\.modelContext) var context
    @Query(sort: \Message.timestamp, order: .reverse) var messages: [Message]
    
    // view specific
    @State private var createMessage = false

    var body: some View {
        NavigationStack {
            Map(coordinateRegion: $region, showsUserLocation: true, userTrackingMode: .constant(.follow), annotationItems: messages,
                annotationContent: { message in
                    MapMarker(coordinate: CLLocationCoordinate2D(latitude: message.latitude, longitude: message.longitude))
                })
            
            toolbarView(createMessage: $createMessage)

        }
        .onAppear {
            locationManager.requestLocationAccess()
            // Assign the context to BluetoothManager to allow saving received messages locally
            bluetoothManager.context = context

            if networkMonitor.isConnected {
                syncMessagesToCloud()
                fetchMessagesFromCloud()
            }
        }
        .onChange(of: locationManager.userLocation) { newLocation in
            if let newLocation = newLocation {
                region.center = newLocation.coordinate
            }
        }
        .sheet(isPresented: $createMessage) {
            NewMessageView(bluetoothManager: bluetoothManager, locationManager: locationManager) // Pass BluetoothManager to NewMessageView
                .presentationDetents([.medium])
        }
    }
}

struct toolbarView: View {
    @Binding var createMessage: Bool
    
    var body: some View {
        HStack(spacing: 75) {
            Button {} label: {
                Text("SOS")
                    .font(.largeTitle)
                    .bold()
            }
            
            NavigationLink {
                HistoryView()
            } label: {
                Image(systemName: "book")
                    .font(.largeTitle)
                 
            }
            
            Button {
                createMessage = true
            } label: {
                Image(systemName: "plus.circle")
                    .font(.largeTitle)
               
            }
        }
    }
}

#Preview {
    MapView()
}

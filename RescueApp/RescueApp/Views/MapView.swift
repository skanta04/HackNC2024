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
    @State private var showSOSAlert = false

    var body: some View {
        NavigationStack {
            Map(coordinateRegion: $region, showsUserLocation: true, userTrackingMode: .constant(.follow), annotationItems: messages,
                annotationContent: { message in
                    MapMarker(coordinate: CLLocationCoordinate2D(latitude: message.latitude, longitude: message.longitude))
                })
            
            toolbarView(createMessage: $createMessage, showSOSAlert: $showSOSAlert, networkMonitor: networkMonitor, bluetoothManager: bluetoothManager, locationManager: locationManager)

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
        .alert(isPresented: $showSOSAlert) {
            Alert(title: Text("SOS Sent"), message: Text("Your SOS alert has been sent to nearby devices."), dismissButton: .default(Text("OK")))
        }
    }
}

struct toolbarView: View {
    @Binding var createMessage: Bool
    @Binding var showSOSAlert: Bool
    @ObservedObject var networkMonitor: NetworkMonitor
    @ObservedObject var bluetoothManager: BluetoothManager
    var locationManager: LocationManager
    
    var body: some View {
        HStack(spacing: 75) {
                    // SOS Button - only active when offline
                    Button(action: {
                        if !networkMonitor.isConnected {
                            sendSOS()
                        }
                    }) {
                        Text("SOS")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(networkMonitor.isConnected ? .gray : .red) // Gray when online, red when offline
                            .opacity(networkMonitor.isConnected ? 0.5 : 1.0) // Semi-transparent when online
                    }
                    .disabled(networkMonitor.isConnected)
            
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
    
    private func sendSOS() {
        // Create an SOS message with current location
        let sosMessage = Message(
            id: UUID(),
            content: "SOS - I need help at my location.",
            latitude: locationManager.userLocation?.coordinate.latitude ?? 0.0,
            longitude: locationManager.userLocation?.coordinate.longitude ?? 0.0,
            timestamp: Date(),
            status: .pendingSync,
            category: .sos
        )

        // Broadcast SOS over Bluetooth
        bluetoothManager.sendMessage(sosMessage)
        showSOSAlert = true // Show confirmation alert
    }
}

#Preview {
    MapView()
}

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
    @Environment(\.modelContext) var context
    @Query(sort: \Message.timestamp, order: .reverse) var messages: [Message]

    @StateObject private var networkMonitor = NetworkMonitor()
    @ObservedObject var bluetoothManager: BluetoothManager
    @ObservedObject var locationManager: LocationManager

    @State private var region: MKCoordinateRegion = .init(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // Default to San Francisco
        span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
    )

    @State var selectedPin: Message?
    @State private var createMessage = false
    @State private var sendSOSAlert = false
    @State private var receiveSOSAlert = false
    @State private var SOSAlertMessage = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: messages,
                    annotationContent: { message in
                    MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: message.latitude, longitude: message.longitude)) {
                        pinView(for: message)
                            .scaleEffect(selectedPin == message ? 1.2 : 1.0)
                            .onTapGesture {
                                selectedPin = message
                            }
                    }
                })
                .ignoresSafeArea()
                
                VStack {
                    if let selectedPin {
                        MessageView(currentLocation: locationManager.userLocation!.coordinate, message: selectedPin)
                            .padding(.top)
                    }
                    Spacer()
                    ToolbarView(createMessage: $createMessage, sendSOSAlert: $sendSOSAlert, networkMonitor: networkMonitor, bluetoothManager: bluetoothManager, locationManager: locationManager)
                        .padding(.bottom)
                }
            }
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
        .onChange(of: messages) { _ in
            if let firstMessage = messages.first, firstMessage.category == .sos {
                receiveSOSAlert = true
                SOSAlertMessage = "Someone needs help at \(firstMessage.latitude), \(firstMessage.longitude)"
            }
        }
        .sheet(isPresented: $createMessage) {
            NewMessageView(bluetoothManager: bluetoothManager, locationManager: locationManager) // Pass BluetoothManager to NewMessageView
                .presentationDetents([.medium])
        }
        .alert(isPresented: $sendSOSAlert) {
            Alert(title: Text("SOS Sent"), message: Text("Your SOS alert has been sent to nearby devices."), dismissButton: .default(Text("OK")))
        }
        .alert(isPresented: $receiveSOSAlert) {
            Alert(title: Text("SOS Received"), message: Text(SOSAlertMessage), dismissButton: .default(Text("OK")))
        }
    }

    @ViewBuilder
    private func pinView(for message: Message) -> some View {
        switch message.category {
        case .flooding:
            FloodPin()
        case .roadClosure:
            RoadPin()
        case .shelter:
            ShelterPin()
        case .sos:
            SosPin()
        case .resource:
            ResourcePin()
        case .other:
            OtherPin()
        }
    }
}

#Preview {
    MapView(bluetoothManager: BluetoothManager(), locationManager: LocationManager())
}

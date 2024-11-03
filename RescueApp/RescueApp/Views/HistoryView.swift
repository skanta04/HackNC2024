//
//  HistoryView.swift
//  RescueApp
//
//  Created by Saishreeya Kantamsetty on 11/2/24.
//

import Foundation
import SwiftData
import SwiftUI
import MapKit

struct HistoryView: View {
    @StateObject private var networkMonitor = NetworkMonitor()
    @StateObject private var bluetoothManager = BluetoothManager()
    @StateObject private var locationManager = LocationManager()
    @Environment(\.modelContext) var context
    
    @State private var createNewBook = false
    @Query(sort: \Message.timestamp, order: .reverse) var messages: [Message]

    var body: some View {
        NavigationStack {
            ScrollView {
                ForEach(messages) { message in
                    MessageView(currentLocation: locationManager.userLocation?.coordinate ?? CLLocationCoordinate2D(latitude: 10.0, longitude: 10.0), message: message)
                }
            }
            .padding()
            .navigationTitle("History")
            .sheet(isPresented: $createNewBook) {
                NewMessageView(bluetoothManager: bluetoothManager, locationManager: locationManager) // Pass BluetoothManager to NewMessageView
                    .presentationDetents([.medium])
            }
            .onAppear {
                // Assign the context to BluetoothManager to allow saving received messages locally
                bluetoothManager.context = context

                if networkMonitor.isConnected {
                    syncMessagesToCloud()
                    fetchMessagesFromCloud()
                }
            }
            .onChange(of: networkMonitor.isConnected) {
                if networkMonitor.isConnected {
                    print("Network status changed: Online")
                    syncMessagesToCloud()
                    print("i synced messages")
                    fetchMessagesFromCloud()
                } else {
                    print("Network status changed: Offline")
                }
            }
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()


#Preview {
    HistoryView()
}

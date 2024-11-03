//
//  ToolbarView.swift
//  RescueApp
//
//  Created by Alexandra Marum on 11/3/24.
//

import SwiftUI

struct ToolbarView: View {
    @Binding var createMessage: Bool
    @Binding var sendSOSAlert: Bool
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
        sendSOSAlert = true // Show confirmation alert
    }
}

#Preview {
    ToolbarView(createMessage: .constant(false), sendSOSAlert: .constant(false), networkMonitor: NetworkMonitor(), bluetoothManager: BluetoothManager(), locationManager: LocationManager())
}

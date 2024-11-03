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
         HStack(spacing: 40) {
             // SOS Button - Only active when offline
             Button(action: {
                 if !networkMonitor.isConnected {
                     sendSOS()
                 }
             }) {
                 VStack {
                     Image(systemName: "sos.circle.fill")
                         .font(.system(size: 50))
                         .foregroundStyle(networkMonitor.isConnected ? .gray : Color("red"))
                         .opacity(networkMonitor.isConnected ? 0.6 : 1.0)
                     Text("SOS")
                         .bold()
                         .font(.footnote)
                         .fontDesign(.rounded)
                         .foregroundStyle(.white)
                 }
             }
             .disabled(networkMonitor.isConnected)
             
             NavigationLink(destination: HistoryView()) {
                 VStack {
                     Image(systemName: "list.bullet.circle.fill")
                         .font(.system(size: 50))
                         .foregroundStyle(Color("lightblue"))
                     Text("History")
                         .bold()
                         .font(.footnote)
                         .fontDesign(.rounded)
                         .foregroundStyle(.white)
                 }
             }
             
             Button {
                 createMessage = true
             } label: {
                 VStack {
                     Image(systemName: "plus.circle.fill")
                         .font(.system(size: 50))
                         .foregroundStyle(Color("green"))
                     Text("Message")
                         .bold()
                         .font(.footnote)
                         .fontDesign(.rounded)
                         .foregroundStyle(.white)
                 }
             }
         }
         .padding(.horizontal, 40)
         .padding(.vertical, 15)
         .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
         .shadow(radius: 8, y: 4) // Soft shadow for a floating effect
         .padding(.bottom, 20)
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

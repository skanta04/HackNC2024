//
//  ContentView.swift
//  RescueApp
//
//  Created by Saishreeya Kantamsetty on 11/2/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var bleManager = BluetoothManager()
    @StateObject private var locationManager = LocationManager()
    @State private var isPeripheral = false // Toggle to choose between Central and Peripheral
    @State private var messageToSend: String = ""
    
    var body: some View {
        if locationManager.hasLocationAccess {
            MapView(locationManager: locationManager)
        }
        VStack {
            Text("Bluetooth Messaging")
                .font(.largeTitle)
                .padding()
            
            TextField("Enter Message", text: $messageToSend)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Send Message") {
                let newMessage = Message(
                    id: UUID(),
                    content: messageToSend,
                    latitude: 0.0, // or use actual location if available
                    longitude: 0.0, // or use actual location if available
                    timestamp: Date(),
                    status: .pendingSync,
                    category: .other // Set category as appropriate
                )
                bleManager.sendMessage(newMessage)
                messageToSend = "" // Clear the message field
            }
        }
        .onAppear {
            locationManager.requestLocationAccess()
        }
        .padding()
            
        Text("Received Message: \(bleManager.receivedMessage)")
            .padding()
    }
}

#Preview {
    ContentView()
}

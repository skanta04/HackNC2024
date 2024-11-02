//
//  ContentView.swift
//  RescueApp
//
//  Created by Saishreeya Kantamsetty on 11/2/24.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var bleManager = BluetoothManager()
    @StateObject private var locationManager = LocationManager()
    @State private var isPeripheral = false // Toggle to choose between Central and Peripheral
    @State private var messageToSend: String = ""
    
    var body: some View {
        if locationManager.hasLocationAccess {
            MapView(locationManager: locationManager)
        }
        VStack {
            Text("BLE Communication")
                .font(.largeTitle)
                .padding()
            
            // Role Selection Toggle
            Toggle("Act as Peripheral (Sender)", isOn: $isPeripheral)
                .padding()
                .onChange(of: isPeripheral) { newValue in
                    if newValue {
                        bleManager.startAsPeripheral()
                    } else {
                        bleManager.startAsCentral()
                    }
                }
            
            if isPeripheral {
                // Peripheral (Sender) UI
                Text("Enter Message to Send")
                    .font(.headline)
                    .padding(.top)
                
                TextField("Enter Message", text: $messageToSend)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button("Send Message") {
                    bleManager.sendMessage(messageToSend)
                    messageToSend = "" // Clear the message field
                }
                .padding()
            } else {
                // Central (Receiver) UI
                Text("Received Message: \(bleManager.receivedMessage)")
                    .padding()
                    .onAppear {
                        print("Received Message Displayed: \(bleManager.receivedMessage)")
                    }
            }
            
        }
        .onAppear {
            locationManager.requestLocationAccess()
        }
        .padding()
    }
}

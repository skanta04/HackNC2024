//
//  ContentView.swift
//  RescueApp
//
//  Created by Saishreeya Kantamsetty on 11/2/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var bluetoothManager = BluetoothManager()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Bluetooth Testing")
                .font(.title)
                .padding()
            
            Button(action: {
                if bluetoothManager.isBroadcasting {
                    bluetoothManager.stopBroadcastingMessage()
                } else {
                    bluetoothManager.startBroadcastingMessage("Test Message")
                }
            }) {
                Text(bluetoothManager.isBroadcasting ? "Stop Broadcasting" : "Start Broadcasting")
                    .font(.headline)
                    .padding()
                    .background(bluetoothManager.isBroadcasting ? Color.red : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            Button(action: {
                bluetoothManager.startScanning()
            }) {
                Text("Start Scanning")
                    .font(.headline)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

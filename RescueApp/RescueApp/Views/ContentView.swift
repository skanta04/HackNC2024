//
//  ContentView.swift
//  RescueApp
//
//  Created by Saishreeya Kantamsetty on 11/2/24.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var bleManager = BluetoothManager()
    @State private var messageToSend: String = ""
    
    var body: some View {
        VStack {
            Text("Bluetooth Messaging")
                .font(.largeTitle)
                .padding()
            
            TextField("Enter Message", text: $messageToSend)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Send Message") {
                bleManager.sendMessage(messageToSend)
                messageToSend = "" // Clear the message field
            }
            .padding()
            
            Text("Received Message: \(bleManager.receivedMessage)")
                .padding()
        }
        .padding()
    }
}

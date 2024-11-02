//
//  NewMessageView.swift
//  RescueApp
//
//  Created by Saishreeya Kantamsetty on 11/2/24.
//

import SwiftUI

struct NewMessageView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var context
    @ObservedObject var bluetoothManager: BluetoothManager
    
    @State private var content = ""
    @State private var latitude = 0.0
    @State private var longitude = 0.0
    @State private var timestamp = Date()
    @State private var status: MessageStatus = .pendingSync
    @State private var category: MessageCategory = .roadClosure
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Message Details")) {
                    TextField("Content", text: $content)
                                
                    HStack {
                        Text("Latitude")
                        TextField("Latitude", value: $latitude, formatter: NumberFormatter())
                            .keyboardType(.decimalPad)
                    }
                                
                    HStack {
                        Text("Longitude")
                        TextField("Longitude", value: $longitude, formatter: NumberFormatter())
                            .keyboardType(.decimalPad)
                    }
                                
                    DatePicker("Timestamp", selection: $timestamp, displayedComponents: .date)
                                
                    Picker("Status", selection: $status) {
                        Text("Pending Sync").tag(MessageStatus.pendingSync)
                        Text("Synced").tag(MessageStatus.synced)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                                
                    Picker("Category", selection: $category) {
                        Text("Road Closure").tag(MessageCategory.roadClosure)
                        Text("Flooding").tag(MessageCategory.flooding)
                        Text("Shelter").tag(MessageCategory.shelter)
                        Text("Resource").tag(MessageCategory.resource)
                        Text("SOS").tag(MessageCategory.sos)
                        Text("Other").tag(MessageCategory.other)
                    }
                }
                            
                Button("Save Message") {
                    let newMessage = Message(
                        id: UUID(),
                        content: content,
                        latitude: latitude,
                        longitude: longitude,
                        timestamp: timestamp,
                        status: status,
                        category: category
                    )

                    context.insert(newMessage) // Save locally
                    bluetoothManager.sendMessage(content) // Send message via Bluetooth
                    dismiss() // Dismiss view
                }
                .buttonStyle(.borderedProminent)
            }
            .navigationTitle("New Messagae")
        }
    }
}

//#Preview {
    //NewMessageView()
//}

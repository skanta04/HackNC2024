//
//  HistoryView.swift
//  RescueApp
//
//  Created by Saishreeya Kantamsetty on 11/2/24.
//

import Foundation
import SwiftData
import SwiftUI

struct HistoryView: View {
    @StateObject private var networkMonitor = NetworkMonitor()
    @StateObject private var bluetoothManager = BluetoothManager()
    @StateObject private var locationManager = LocationManager()
    @Environment(\.modelContext) var context
    
    @State private var createNewBook = false
    @Query(sort: \Message.timestamp, order: .reverse) var messages: [Message]

    var body: some View {
        NavigationStack {
            List(messages) { message in
                VStack(alignment: .leading) {
                    Text(message.content)
                        .font(.headline)
                    Text("Category: \(message.category.rawValue)")
                    Text("Status: \(message.status.rawValue)")
                    Text("Timestamp: \(message.timestamp, formatter: dateFormatter)")
                        .font(.caption)
                }
            }
            .padding()
            .navigationTitle("History")
            .toolbar {
                Button {
                    createNewBook = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .imageScale(.large)
                }
            }
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

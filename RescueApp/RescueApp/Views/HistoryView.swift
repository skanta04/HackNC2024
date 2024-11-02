//
//  HistoryView.swift
//  RescueApp
//
//  Created by Saishreeya Kantamsetty on 11/2/24.
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @State private var createNewBook = false
    @Environment(\.modelContext) var context
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
                NewMessageView()
                    .presentationDetents([.medium])
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

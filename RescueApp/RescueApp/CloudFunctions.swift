//
//  CloudFunctions.swift
//  RescueApp
//
//  Created by Saishreeya Kantamsetty on 11/2/24.


import Foundation

extension HistoryView {
    // Push unsynced messages to the cloud
    func syncMessagesToCloud() {
        let pendingMessages = messages.filter { $0.status == .pendingSync }
        for message in pendingMessages {
            postToCloud(message) { success in
                if success {
                    message.status = .synced // Set status to synced after successful upload
                    try? context.save()
                }
            }
        }
    }

    
    private func postToCloud(_ message: Message, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "http://98.80.6.198:8000/messages") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let jsonMessage = try? JSONEncoder().encode(message)
        request.httpBody = jsonMessage

        URLSession.shared.dataTask(with: request) { data, response, error in
            completion(error == nil)
        }.resume()
    }
    
    // Fetch all messages from the cloud and merge into local storage
    func fetchMessagesFromCloud() {
        guard let url = URL(string: "https://your-public-api-url/messages") else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                var cloudMessages = try? JSONDecoder().decode([Message].self, from: data)
                cloudMessages?.forEach { $0.status = .synced } // Mark fetched messages as synced

                DispatchQueue.main.async {
                    self.mergeCloudMessages(cloudMessages ?? [])
                }
            }
        }.resume()
    }

    
    private func mergeCloudMessages(_ cloudMessages: [Message]) {
        for cloudMessage in cloudMessages {
            if messages.allSatisfy({ $0.id != cloudMessage.id }) {
                context.insert(cloudMessage)
            }
        }
        try? context.save()
    }
}

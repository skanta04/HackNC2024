//
//  CloudFunctions.swift
//  RescueApp
//
//  Created by Saishreeya Kantamsetty on 11/2/24.
//

import Foundation

extension HistoryView {
    // if I am online and I have pending messages to sync, this function will be called to push them to the cloud
    func syncMessagesToCloud() {
        let pendingMessages = messages.filter { $0.status == .pendingSync }
        for message in pendingMessages {
            postToCloud(message) { success in
                if success {
                    message.status = .synced
                    try? context.save()
                }
            }
        }
    }
    
    
    private func postToCloud(_ message: Message, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "https://your-public-api-url/messages") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let jsonMessage = try? JSONEncoder().encode(message)
        request.httpBody = jsonMessage

        URLSession.shared.dataTask(with: request) { data, response, error in
            completion(error == nil)
        }.resume()
    }
    
    func fetchMessagesFromCloud() {
        guard let url = URL(string: "https://your-public-api-url/messages") else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                let cloudMessages = try? JSONDecoder().decode([Message].self, from: data)
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

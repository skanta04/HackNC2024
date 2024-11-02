//
//  NetworkMonitor.swift
//  RescueApp
//
//  Created by Saishreeya Kantamsetty on 11/2/24.
//

import Foundation
import Network

class NetworkMonitor: ObservableObject {
    private var monitor = NWPathMonitor()
    private let queue = DispatchQueue.global()

    @Published var isConnected = false

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }
}

//
//  NetworkMonitor.swift
//  RescueApp
//
//  Created by Saishreeya Kantamsetty on 11/2/24.


import Network
import SwiftUI

class NetworkMonitor: ObservableObject {
    private var monitor = NWPathMonitor()
    private let queue = DispatchQueue.global()
    
    @Published var isConnected: Bool = false
    
    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = (path.status == .satisfied)
                print("NetworkMonitor detected network change: \(self?.isConnected == true ? "Online" : "Offline")")
            }
        }
        monitor.start(queue: queue)
    }
}



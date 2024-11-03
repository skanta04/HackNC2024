//
//  RescueAppApp.swift
//  RescueApp
//
//  Created by Saishreeya Kantamsetty on 11/2/24.
//

import SwiftUI
import SwiftData

@main
struct RescueAppApp: App {
    var body: some Scene {
        WindowGroup {
            MapView()
        }
        .modelContainer(for: Message.self)
    }
}

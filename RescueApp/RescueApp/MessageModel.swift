//
//  MessageModel.swift
//  RescueApp
//
//  Created by Saishreeya Kantamsetty on 11/2/24.
//

import Foundation

struct Message {
    var id: UUID
    var content: String
    var latitude: Double
    var longitude: Double
    var timestamp: Date
    var status: MessageStatus
    var category: MessageCategory
}

enum MessageStatus: String, Codable {
    case pendingSync = "pending_sync"
    case synced = "synced"
}

enum MessageCategory: String, Codable {
    case roadClosure = "Road Closure"
    case flooding = "Flooding"
    case shelter = "Shelter"
    case resource = "Resource"
    case sos = "SOS"
    case other = "Other"
}

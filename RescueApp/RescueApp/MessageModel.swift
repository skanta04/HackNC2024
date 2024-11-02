//
//  MessageModel.swift
//  RescueApp
//
//  Created by Saishreeya Kantamsetty on 11/2/24.
//

import Foundation
import SwiftData

@Model
class Message {
    @Attribute(.unique) var id: UUID
    var content: String
    var latitude: Double
    var longitude: Double
    var timestamp: Date
    var status: MessageStatus
    var category: MessageCategory
    
    init(id: UUID, content: String, latitude: Double, longitude: Double, timestamp: Date, status: MessageStatus, category: MessageCategory) {
        self.id = id
        self.content = content
        self.latitude = latitude
        self.longitude = longitude
        self.timestamp = timestamp
        self.status = status
        self.status = status
        self.category = category
    }
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

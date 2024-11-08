//
//  MessageModel.swift
//  RescueApp
//
//  Created by Saishreeya Kantamsetty on 11/2/24.
//

import Foundation
import SwiftData

@Model
class Message: Identifiable, Codable {
    
    @Attribute(.unique) var id: UUID
    var content: String
    var latitude: Double
    var longitude: Double
    var timestamp: Date
    var status: MessageStatus
    var category: MessageCategory
    
    init(id: UUID = UUID(), content: String, latitude: Double, longitude: Double, timestamp: Date, status: MessageStatus, category: MessageCategory) {
        self.id = id
        self.content = content
        self.latitude = latitude
        self.longitude = longitude
        self.timestamp = timestamp
        self.status = status
        self.status = status
        self.category = category
    }
    
    // I need to add the conformance by hand because I am usign @model
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        content = try container.decode(String.self, forKey: .content)
        latitude = try container.decode(Double.self, forKey: .latitude)
        longitude = try container.decode(Double.self, forKey: .longitude)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        status = try container.decode(MessageStatus.self, forKey: .status)
        category = try container.decode(MessageCategory.self, forKey: .category)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(content, forKey: .content)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(status, forKey: .status)
        try container.encode(category, forKey: .category)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case content
        case latitude
        case longitude
        case timestamp
        case status
        case category
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

// examples

extension Message {
    static let example1 = Message(id: UUID(),
                                  content: "Hamilton Hall flooding",
                                  latitude: 35.911595,
                                  longitude:  -79.048759,
                                  timestamp: Date(),
                                  status: .synced,
                                  category: .flooding)
    static let example2 = Message(id: UUID(),
                                  content: "Emergency on Franklin Street!",
                                  latitude: 35.9132,
                                  longitude: -79.05584,
                                  timestamp: Date(),
                                  status: .synced,
                                  category: .sos)
    static let example3 = Message(id: UUID(),
                                  content: "Student stores offering water",
                                  latitude: 35.91,
                                  longitude: -79.05,
                                  timestamp: Date(),
                                  status: .synced,
                                  category: .resource)
    static let example4 = Message(id: UUID(),
                                  content: "Toilet paper needed at Morrison!",
                                  latitude: 35.904493,
                                  longitude: -79.046159,
                                  timestamp: Date(),
                                  status: .synced,
                                  category: .other)
}

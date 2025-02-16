//
//  Users.swift
//  AvitoInternshipWinter2025
//
//  Created by Никита Абаев on 17.02.2025.
//


import Foundation

// MARK: - User

struct Users: Codable {
    let id: Int
    let email: String
    let name: String
    let role: String
    let avatar: String
    let creationAt, updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, email, name, role, avatar, creationAt, updatedAt
    }
    
    static let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        email = try container.decode(String.self, forKey: .email)
        name = try container.decode(String.self, forKey: .name)
        role = try container.decode(String.self, forKey: .role)
        avatar = try container.decode(String.self, forKey: .avatar)
        
    
        let creationAtString = try container.decode(String.self, forKey: .creationAt)
        let updatedAtString = try container.decode(String.self, forKey: .updatedAt)
        
        creationAt = Users.dateFormatter.date(from: creationAtString) ?? Date()
        updatedAt = Users.dateFormatter.date(from: updatedAtString) ?? Date()
    }
}
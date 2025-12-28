//
//  ProjectModel.swift
//  OmniAdmin
//
//  Created by Nunu Nugraha on 25/12/25.
//

import Foundation

struct TechStack: Codable, Identifiable, Hashable {
    let id: UUID
    var name: String
}

struct Project: Codable, Identifiable, Hashable {
    let id: UUID
    var title: String
    var shortDesc: String?
    var description: String?
    var category: String?
    var isHero: Bool
    var techStacks: [TechStack]?
    
    var linkGithub: String?
    var linkDemo: String?
    var linkStore: String?
    var thumbnailUrl: String?
    
    var techStackIDs: [UUID]?

    enum CodingKeys: String, CodingKey {
        case id, title, description, category, isHero
        // FIX: Samakan dengan nama variabel di Vapor (CamelCase)
        case shortDesc = "shortDesc"
        case techStacks = "techStacks"
        case linkGithub = "linkGithub"
        case linkDemo = "linkDemo"
        case linkStore = "linkStore"
        case thumbnailUrl = "thumbnailUrl"
        case techStackIDs = "techStackIDs"
    }
}

// Model bantuan tetap perlu buat Delete
struct EmptyResponse: Codable {}

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
    var shortDesc: String
    var description: String
    var category: String
    var isHero: Bool
    var techStacks: [TechStack]
    
    // Sesuaikan dengan database Vapor
    var linkGithub: String?
    var linkDemo: String?
    var linkStore: String?
    var thumbnailUrl: String?
    
    var techStackIDs: [UUID]?

    enum CodingKeys: String, CodingKey {
        case id, title, description, category, isHero
        case shortDesc = "short_desc"
        case techStacks = "tech_stacks"
        case techStackIDs = "tech_stack_ids"
        case linkGithub = "link_github"
        case linkDemo = "link_demo"
        case linkStore = "link_store"
        case thumbnailUrl = "thumbnail_url"
    }
}

// Model bantuan tetap perlu buat Delete
struct EmptyResponse: Codable {}

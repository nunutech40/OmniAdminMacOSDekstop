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
    var description: String
    var category: String
    var url: String
    var isHero: Bool
    // Update: Backend lo mengembalikan objek TechStack, bukan String
    var techStacks: [TechStack]
    
    // Properti bantuan saat mengirim data (Create/Update) ke Vapor
    var techStackIDs: [UUID]?

    enum CodingKeys: String, CodingKey {
        case id, title, description, category, isHero
        case url = "url" // Sesuaikan dengan field di PortfolioController
        case techStacks = "tech_stacks" // Eager loaded dari Vapor
        case techStackIDs = "tech_stack_ids" // Digunakan untuk DTO
    }
}

// Model bantuan tetap perlu buat Delete
struct EmptyResponse: Codable {}

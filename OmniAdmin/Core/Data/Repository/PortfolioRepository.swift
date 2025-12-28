//
//  PortfolioRepository.swift
//  OmniAdmin
//
//  Created by Nunu Nugraha on 27/12/25.
//

import Foundation

protocol PortfolioRepositoryProtocol {
    func fetchAll() async throws -> [Project]
    func createProject(
        title: String,
        shortDesc: String,
        description: String,
        category: String,
        linkGithub: String,
        linkDemo: String,
        isHero: Bool,
        techIDs: [UUID]
    ) async throws -> Project
    func updateProject(_ project: Project) async throws -> Project
    func deleteProject(id: UUID) async throws
}

final class PortfolioRepository: PortfolioRepositoryProtocol {
    private let client: APIClient
    
    init(client: APIClient) {
        self.client = client
    }
    
    func fetchAll() async throws -> [Project] {
        return try await client.request(APIConstants.Endpoints.portfolios, method: .get)
    }
    
    func createProject(title: String, shortDesc: String, description: String, category: String, linkGithub: String, linkDemo: String, isHero: Bool, techIDs: [UUID]) async throws -> Project {
        let parameters: [String: Any?] = [
            "title": title,
            "slug": title.lowercased().replacingOccurrences(of: " ", with: "-"),
            "shortDesc": shortDesc.isEmpty ? nil : shortDesc, // Kirim nil kalo kosong
            "description": description.isEmpty ? nil : description,
            "category": category.isEmpty ? nil : category,
            "linkGithub": linkGithub.isEmpty ? nil : linkGithub,
            "linkDemo": linkDemo.isEmpty ? nil : linkDemo,
            "isHero": isHero,
            "techStackIDs": techIDs.map { $0.uuidString }
        ]
        return try await client.request(APIConstants.Endpoints.portfolios, method: .post, parameters: parameters)
    }
    
    func updateProject(_ project: Project) async throws -> Project {
        let parameters: [String: Any?] = [
            "title": project.title,
            "slug": project.title.lowercased().replacingOccurrences(of: " ", with: "-"),
            "shortDesc": project.shortDesc,
            "description": project.description,
            "category": project.category,
            "linkGithub": project.linkGithub,
            "linkDemo": project.linkDemo,
            "isHero": project.isHero,
            "techStackIDs": project.techStackIDs ?? []
        ]
        let endpoint = "\(APIConstants.Endpoints.portfolios)/\(project.id.uuidString)"
        return try await client.request(endpoint, method: .put, parameters: parameters)
    }
    
    func deleteProject(id: UUID) async throws {
        let endpoint = "\(APIConstants.Endpoints.portfolios)/\(id.uuidString)"
        let _: EmptyResponse = try await client.request(endpoint, method: .delete)
    }
}

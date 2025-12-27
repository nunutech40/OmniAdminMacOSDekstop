//
//  PortfolioRepository.swift
//  OmniAdmin
//
//  Created by Nunu Nugraha on 27/12/25.
//

import Foundation

protocol PortfolioRepositoryProtocol {
    func fetchAll() async throws -> [Project]
    func createProject(title: String, description: String, link: String, category: String, techIDs: [UUID]) async throws -> Project
    func updateProject(_ project: Project) async throws -> Project
    func deleteProject(id: UUID) async throws
}

final class PortfolioRepository: PortfolioRepositoryProtocol {
    private let client: APIClient
    // Storage dibuang karena "porto langsung ke be"
    
    init(client: APIClient) {
        self.client = client
    }
    
    func fetchAll() async throws -> [Project] {
        return try await client.request(
            APIConstants.Endpoints.portfolios,
            method: .get
        )
    }
    
    func createProject(title: String, description: String, link: String, category: String, techIDs: [UUID]) async throws -> Project {
        let parameters: [String: Any] = [
            "title": title,
            "description": description,
            "url": link,
            "category": category,
            "is_hero": false,
            "tech_stack_ids": techIDs.map { $0.uuidString }
        ]
        
        return try await client.request(
            APIConstants.Endpoints.portfolios,
            method: .post,
            parameters: parameters
        )
    }
    
    func updateProject(_ project: Project) async throws -> Project {
        let techIDs = project.techStackIDs?.map { $0.uuidString } ?? []
        let parameters: [String: Any] = [
            "title": project.title,
            "description": project.description,
            "url": project.url,
            "category": project.category,
            "is_hero": project.isHero,
            "tech_stack_ids": techIDs
        ]
        
        let endpoint = "\(APIConstants.Endpoints.portfolios)/\(project.id.uuidString)"
        return try await client.request(
            endpoint,
            method: .put,
            parameters: parameters
        )
    }
    
    func deleteProject(id: UUID) async throws {
        let endpoint = "\(APIConstants.Endpoints.portfolios)/\(id.uuidString)"
        let _: EmptyResponse = try await client.request(endpoint, method: .delete)
    }
}

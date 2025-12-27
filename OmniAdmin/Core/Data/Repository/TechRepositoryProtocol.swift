//
//  TechRepositoryProtocol.swift
//  OmniAdmin
//
//  Created by Nunu Nugraha on 27/12/25.
//

import Foundation

protocol TechRepositoryProtocol {
    func fetchAllTechs() async throws -> [TechStack]
    func createTech(name: String) async throws -> TechStack
    func updateTech(id: UUID, name: String) async throws -> TechStack
    func deleteTech(id: UUID) async throws
}

final class TechRepository: TechRepositoryProtocol {
    private let client: APIClient
    private let storage: LocalPersistenceProtocol
    private let techCacheKey = "kCachedTechStacks"
    
    init(client: APIClient, storage: LocalPersistenceProtocol) {
        self.client = client
        self.storage = storage
    }
    
    func fetchAllTechs() async throws -> [TechStack] {
        let response: [TechStack] = try await client.request(
            APIConstants.Endpoints.techs,
            method: .get
        )
        // Simpan master data ke cache
        storage.save(response, key: techCacheKey)
        return response
    }
    
    func createTech(name: String) async throws -> TechStack {
        let parameters: [String: Any] = ["name": name]
        let newTech: TechStack = try await client.request(
            APIConstants.Endpoints.techs,
            method: .post,
            parameters: parameters
        )
        
        // Update cache lokal
        var cached: [TechStack] = storage.get(key: techCacheKey) ?? []
        cached.append(newTech)
        storage.save(cached, key: techCacheKey)
        
        return newTech
    }
    
    func updateTech(id: UUID, name: String) async throws -> TechStack {
        let parameters: [String: Any] = ["name": name]
        let endpoint = "\(APIConstants.Endpoints.techs)/\(id.uuidString)"
        
        let updated: TechStack = try await client.request(
            endpoint,
            method: .put,
            parameters: parameters
        )
        
        // Update item di cache
        var cached: [TechStack] = storage.get(key: techCacheKey) ?? []
        if let index = cached.firstIndex(where: { $0.id == id }) {
            cached[index] = updated
            storage.save(cached, key: techCacheKey)
        }
        
        return updated
    }
    
    func deleteTech(id: UUID) async throws {
        let endpoint = "\(APIConstants.Endpoints.techs)/\(id.uuidString)"
        let _: EmptyResponse = try await client.request(endpoint, method: .delete)
        
        // Hapus dari cache
        var cached: [TechStack] = storage.get(key: techCacheKey) ?? []
        cached.removeAll { $0.id == id }
        storage.save(cached, key: techCacheKey)
    }
}

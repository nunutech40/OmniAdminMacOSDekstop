//
//  UserRepository.swift
//  OmniAdmin
//
//  Created by Nunu Nugraha on 26/12/25.
//

import Foundation

protocol UserRepositoryProtocol {
    func login(username: String, password: String) async throws -> UserInfo
    func logout()
}

final class UserRepository: UserRepositoryProtocol {
    private let client: APIClient
    private let secureStorage: SecureStorageProtocol
    private let storage: LocalPersistenceProtocol
    
    private let accessTokenKey = "accessToken"
    private let userSessionKey = "kSessionUser"

    init(
        client: APIClient,
        secureStorage: SecureStorageProtocol,
        storage: LocalPersistenceProtocol
    ) {
        self.client = client
        self.secureStorage = secureStorage
        self.storage = storage
    }

    func login(username: String, password: String) async throws -> UserInfo {
        let parameters: [String: Any] = [
            "username": username,
            "password": password
        ]
        
        // 1. Hit API via APIClient
        // Tipe T di sini adalah LoginResponse (karena data: { token, user })
        let response: LoginResponse = try await client.request(
            APIConstants.Endpoints.login,
            method: .post,
            parameters: parameters
        )
        
        // 2. SIDE EFFECT: Simpan token ke Keychain & User ke UserDefaults
        try secureStorage.saveToken(response.token, key: accessTokenKey)
        storage.save(response.user, key: userSessionKey)
        
        return response.user
    }

    func logout() {
        try? secureStorage.clearAll()
        storage.remove(key: userSessionKey)
    }
}

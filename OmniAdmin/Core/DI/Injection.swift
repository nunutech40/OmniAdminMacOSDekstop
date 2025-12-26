//
//  Injection.swift
//  OmniAdmin
//
//  Created by Nunu Nugraha on 26/12/25.
//

final class Injection {
    static let shared = Injection()
    private init() {}

    // 1. Singleton Dependencies (Agar storage-nya sama di semua modul)
    private let secureStorage: SecureStorageProtocol = SecureStorage()
    private let localStorage: LocalPersistenceProtocol = LocalPersistence()

    // 2. Provide API Client (Gunakan singleton yang sudah punya interceptor)
    func provideAPIClient() -> APIClient {
        return APIClient.shared
    }

    // 3. Provide Auth Manager (Untuk Global State)
    func provideAuthManager() -> AuthenticationManager {
        // Harus pake instance storage yang sama supaya datanya sinkron
        return AuthenticationManager(
            secureStorage: secureStorage,
            storage: localStorage
        )
    }

    // 4. Provide User Repository
    func provideUserRepository() -> UserRepositoryProtocol {
        return UserRepository(
            client: provideAPIClient(),
            secureStorage: secureStorage, // Buat save token pas login
            storage: localStorage
        )
    }
}

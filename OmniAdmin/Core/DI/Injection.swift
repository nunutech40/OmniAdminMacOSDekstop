//
//  Injection.swift
//  OmniAdmin
//
//  Created by Nunu Nugraha on 26/12/25.
//

final class Injection {
    static let shared = Injection()
    private init() {}

    private let secureStorage: SecureStorageProtocol = SecureStorage()
    private let localStorage: LocalPersistenceProtocol = LocalPersistence()

    // Provide AuthManager (Global)
    func provideAuthManager() -> AuthenticationManager {
        return AuthenticationManager(secureStorage: secureStorage, storage: localStorage)
    }

    // Provide User Repository
    func provideUserRepository() -> UserRepositoryProtocol {
        return UserRepository(
            client: APIClient.shared, // Sudah pake singleton lo tadi
            secureStorage: secureStorage,
            storage: localStorage
        )
    }
}

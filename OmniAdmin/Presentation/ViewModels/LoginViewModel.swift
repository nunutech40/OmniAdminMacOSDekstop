//
//  LoginViewModel.swift
//  OmniAdmin
//
//  Created by Nunu Nugraha on 26/12/25.
//

import Foundation

@MainActor
final class LoginViewModel: ObservableObject {
    private let repository: UserRepositoryProtocol
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    @Published var isError: Bool = false
    
    // Untuk navigasi sukses di View
    @Published var loggedInUser: UserInfo?

    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }

    func login(username: String, password: String) async {
        guard !username.isEmpty && !password.isEmpty else {
            self.errorMessage = "Isi dulu semua field-nya, Nu."
            self.isError = true
            return
        }

        isLoading = true
        isError = false
        
        do {
            let user = try await repository.login(username: username, password: password)
            self.loggedInUser = user
        } catch let error as APIError {
            self.errorMessage = error.localizedDescription
            self.isError = true
        } catch {
            self.errorMessage = "Terjadi kesalahan sistem."
            self.isError = true
        }
        
        isLoading = false
    }
} 

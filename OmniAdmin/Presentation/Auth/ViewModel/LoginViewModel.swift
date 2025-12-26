//
//  LoginViewModel.swift
//  OmniAdmin
//
//  Created by Nunu Nugraha on 26/12/25.
//

import Foundation
import Observation 

@Observable
@MainActor
final class LoginViewModel {
    private let repository: UserRepositoryProtocol
    
    var isLoading: Bool = false
    var errorMessage: String = ""
    var isError: Bool = false
    var loggedInUser: UserInfo?

    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }

    func login(username: String, password: String) async {
        // Reset state di awal
        self.isError = false
        self.errorMessage = ""
        
        // Gunakan extension String lo buat validasi awal
        guard username.isValidUsername || username.isValidEmail else {
            self.errorMessage = "Username atau Email gak valid, Nu."
            self.isError = true
            return
        }
        
        guard password.isValidPassword else {
            self.errorMessage = "Password minimal 8 karakter, Bos."
            self.isError = true
            return
        }

        isLoading = true
        
        do {
            // Nembak API lewat Repository
            let user = try await repository.login(username: username, password: password)
            self.loggedInUser = user
        } catch let error as APIError {
            // Mapping error dari enum APIError lo
            self.errorMessage = error.localizedDescription
            self.isError = true
        } catch {
            self.errorMessage = "Terjadi kesalahan sistem: \(error.localizedDescription)"
            self.isError = true
        }
        
        isLoading = false
    }
}

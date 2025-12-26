//
//  RegisterViewModel.swift
//  OmniAdmin
//
//  Created by Nunu Nugraha on 27/12/25.
//
import Foundation
import Observation

@Observable
@MainActor
final class RegisterViewModel {
    var isLoading = false
    var isError = false
    var errorMessage = ""
    var isSuccess = false
    
    private let repository: UserRepositoryProtocol
    
    // Inject repository lewat init
    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }
    
    func register(username: String, pass: String) async {
        isLoading = true
        isError = false
        
        do {
            // Role kita set default 'admin' sesuai kebutuhan OmniAdmin
            _ = try await repository.register(username: username, password: pass)
            self.isSuccess = true
        } catch {
            self.isError = true
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

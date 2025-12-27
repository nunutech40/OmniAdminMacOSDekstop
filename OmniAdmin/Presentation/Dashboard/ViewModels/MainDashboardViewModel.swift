//
//  MainDashboardViewModel.swift
//  OmniAdmin
//
//  Created by Nunu Nugraha on 27/12/25.
//

import Foundation
import Observation

@Observable
@MainActor
final class MainDashboardViewModel {
    var projects: [Project] = []
    var isLoading = false
    var errorMessage: String?
    
    private let repository: PortfolioRepositoryProtocol
    
    init(repository: PortfolioRepositoryProtocol = Injection.shared.providePortfolioRepository()) {
        self.repository = repository
    }
    
    func loadProjects() async {
        isLoading = true
        errorMessage = nil
        
        do {
            self.projects = try await repository.fetchAll()
        } catch {
            self.errorMessage = "Gagal memuat data: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}

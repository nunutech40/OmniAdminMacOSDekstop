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
        do {
            let results = try await repository.fetchAll()
            self.projects = results
            print("✅ Berhasil Load: \(results.count) data")
        } catch let decodingError as DecodingError {
            // INI BAKAL NGASIH TAU FIELD MANA YANG BIKIN MATI
            print("❌ DECODING ERROR: \(decodingError)")
        } catch {
            print("❌ GENERAL ERROR: \(error)")
        }
        isLoading = false
    }
    
    func deleteProject(id: UUID) async {
        isLoading = true
        errorMessage = nil
        
        do {
            // 1. Panggil API untuk hapus di server
            try await repository.deleteProject(id: id)
            
            // 2. Optimistic Update: Hapus dari list local agar UI langsung berubah
            self.projects.removeAll { $0.id == id }
            
            print("Project deleted successfully: \(id)")
        } catch {
            print("Delete Error: \(error)")
            self.errorMessage = "Gagal menghapus data: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}

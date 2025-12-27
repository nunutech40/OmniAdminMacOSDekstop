//
//  ProjectEditorViewModel.swift
//  OmniAdmin
//
//  Created by Nunu Nugraha on 27/12/25.
//

import Foundation
import Observation

@Observable @MainActor
final class ProjectEditorViewModel {
    var project: Project
    var availableTechs: [TechStack] = [] // Master data dari GET /techs
    var selectedTechIDs: Set<UUID> = []  // ID yang dipilih user
    var newTechName = ""
    var isLoading = false
    
    private let repo = Injection.shared.providePortfolioRepository()
    private let techRepo = Injection.shared.provideTechRepository()

    init(project: Project) {
        self.project = project
        // Sinkronisasi awal: Ambil ID dari objek techStacks yang dikirim Vapor
        self.selectedTechIDs = Set(project.techStacks.map { $0.id })
    }

    func loadMasterData() async {
        isLoading = true
        availableTechs = (try? await techRepo.fetchAllTechs()) ?? []
        isLoading = false
    }

    func addTech() {
        let trimmed = newTechName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        // Cek apakah tech sudah ada di master data
        if let existing = availableTechs.first(where: { $0.name.lowercased() == trimmed.lowercased() }) {
            selectedTechIDs.insert(existing.id)
            newTechName = ""
        } else {
            // Kalau belum ada, lo harus tembak API buat create tech baru dulu
            Task {
                await createNewGlobalTech(name: trimmed)
            }
        }
    }

    private func createNewGlobalTech(name: String) async {
        isLoading = true
        do {
            let newTech = try await techRepo.createTech(name: name)
            self.availableTechs.append(newTech)
            self.selectedTechIDs.insert(newTech.id)
            self.newTechName = ""
        } catch {
            print("Gagal buat tech: \(error)")
        }
        isLoading = false
    }

    func saveChanges() async {
        isLoading = true
        // Update property techStackIDs sebelum kirim ke Repository
        project.techStackIDs = Array(selectedTechIDs)
        
        do {
            let updated = try await repo.updateProject(project)
            self.project = updated
            print("Update sukses!")
        } catch {
            print("Update gagal: \(error)")
        }
        isLoading = false
    }
}

//
//  AddProjectViewModel.swift
//  OmniAdmin
//
//  Created by Nunu Nugraha on 28/12/25.
//

import Foundation
import Observation

@Observable @MainActor
class AddProjectViewModel {
    // Form States
    var title = ""
    var shortDesc = ""
    var description = ""
    var category = "macOS App"
    var linkGithub = ""
    var linkDemo = ""
    var isHero = false
    
    // UI States
    var isSaving = false
    var masterTechs: [TechStack] = []
    var selectedTechIDs: Set<UUID> = []
    var newTechName = ""
    
    private let portfolioRepo = Injection.shared.providePortfolioRepository()
    private let techRepo = Injection.shared.provideTechRepository()
    var projectToEdit: Project?

    init(projectToEdit: Project? = nil) {
        self.projectToEdit = projectToEdit
        if let project = projectToEdit {
            self.title = project.title
            self.shortDesc = project.shortDesc
            self.description = project.description
            self.category = project.category
            self.linkGithub = project.linkGithub ?? ""
            self.linkDemo = project.linkDemo ?? ""
            self.isHero = project.isHero
            self.selectedTechIDs = Set(project.techStacks.map { $0.id })
        }
    }

    func loadTechs() async {
        masterTechs = (try? await techRepo.fetchAllTechs()) ?? []
    }

    func createTech() async {
        guard !newTechName.isEmpty else { return }
        if let new = try? await techRepo.createTech(name: newTechName) {
            masterTechs.append(new)
            selectedTechIDs.insert(new.id)
            newTechName = ""
        }
    }

    func save(onSuccess: @escaping () -> Void) async {
        isSaving = true
        defer { isSaving = false } // Otomatis jadi false saat beres (berhasil/gagal)
        
        do {
            if var project = projectToEdit {
                project.title = title
                project.shortDesc = shortDesc
                project.description = description
                project.category = category
                project.linkGithub = linkGithub
                project.linkDemo = linkDemo
                project.isHero = isHero
                project.techStackIDs = Array(selectedTechIDs)
                _ = try await portfolioRepo.updateProject(project)
            } else {
                _ = try await portfolioRepo.createProject(
                    title: title, shortDesc: shortDesc, description: description,
                    category: category, linkGithub: linkGithub, linkDemo: linkDemo,
                    isHero: isHero, techIDs: Array(selectedTechIDs)
                )
            }
            onSuccess()
        } catch {
            print("❌ Save Error: \(error)")
        }
    }
}

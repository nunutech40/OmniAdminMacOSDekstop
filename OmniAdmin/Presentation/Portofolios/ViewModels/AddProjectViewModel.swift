//
//  AddProjectViewModel.swift
//  OmniAdmin
//
//  Created by Nunu Nugraha on 28/12/25.
//

import Foundation
import Observation
import AppKit

@Observable @MainActor
class AddProjectViewModel {
    // Form States
    var title = ""
    var shortDesc = ""
    var description = ""
    var category = "macOS App"
    var linkGithub = ""
    var linkDemo = ""
    var linkStore = ""
    var thumbnailUrl = ""
    var isHero = false
    
    // UI States
    var isSaving = false
    var showSuccessAlert = false // Buat nampilin notif berhasil
    var errorMessage: String? = nil
    
    var masterTechs: [TechStack] = []
    var selectedTechIDs: Set<UUID> = []
    var newTechName = ""
    
    var selectedImageURL: URL?
    var previewImage: NSImage?
    
    private let portfolioRepo = Injection.shared.providePortfolioRepository()
    private let techRepo = Injection.shared.provideTechRepository()
    private let mediaRepo = Injection.shared.provideMediaRepository()
    
    var projectToEdit: Project?
    
    init(projectToEdit: Project? = nil) {
        self.projectToEdit = projectToEdit
        if let project = projectToEdit {
            self.title = project.title
            self.shortDesc = project.shortDesc ?? ""
            self.description = project.description ?? ""
            self.category = project.category ?? ""
            self.linkGithub = project.linkGithub ?? ""
            self.linkDemo = project.linkDemo ?? ""
            self.linkStore = project.linkStore ?? ""
            self.thumbnailUrl = project.thumbnailUrl ?? ""
            self.isHero = project.isHero
            self.selectedTechIDs = Set(project.techStacks?.map { $0.id } ?? [])
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
    
    func save() async {
        isSaving = true
        errorMessage = nil
        
        do {
            // 1. UPLOAD IMAGE DULU
            if let url = selectedImageURL {
                guard url.startAccessingSecurityScopedResource() else { return }
                defer { url.stopAccessingSecurityScopedResource() }
                
                guard let originalImage = NSImage(contentsOf: url),
                      let compressedData = originalImage.resizedTo(maxSize: 1000) else {
                    throw NSError(domain: "ImageError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Gagal kompres gambar"])
                }
                
                let fileName = url.lastPathComponent
                let uploadedPath = try await mediaRepo.uploadImage(
                    data: compressedData as Data,
                    fileName: fileName,
                    mimeType: "image/jpeg"
                )
                
                self.thumbnailUrl = uploadedPath
                // Setelah sukses upload, hapus selectedImageURL biar gak re-upload kalau klik save lagi
                self.selectedImageURL = nil
            }
            
            // 2. BARU SAVE PORTO
            if var project = projectToEdit {
                project.title = title
                project.shortDesc = shortDesc
                project.description = description
                project.category = category
                project.thumbnailUrl = thumbnailUrl
                project.linkGithub = linkGithub
                project.linkDemo = linkDemo
                project.linkStore = linkStore // Pastikan ini masuk
                project.isHero = isHero
                project.techStackIDs = Array(selectedTechIDs)
                _ = try await portfolioRepo.updateProject(project)
            } else {
                _ = try await portfolioRepo.createProject(
                    title: title,
                    shortDesc: shortDesc,
                    description: description,
                    category: category,
                    thumbnailUrl: thumbnailUrl,
                    linkGithub: linkGithub,
                    linkDemo: linkDemo,
                    linkStore: linkStore,
                    isHero: isHero,
                    techIDs: Array(selectedTechIDs)
                )
            }
            
            showSuccessAlert = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isSaving = false
    }
    
    func handleImageSelection(url: URL) {
        // 1. Minta izin akses (Wajib di macOS Sandbox)
        guard url.startAccessingSecurityScopedResource() else {
            self.errorMessage = "Permission denied to access the image."
            return
        }
        
        // Pastiin kita stop aksesnya setelah beres biar gak memory leak/security hole
        defer { url.stopAccessingSecurityScopedResource() }
        
        self.selectedImageURL = url
        
        // 2. Coba baca data dengan error handling biar keliatan kalau gagal
        do {
            let data = try Data(contentsOf: url)
            self.previewImage = NSImage(data: data)
            print("Preview Image Loaded: \(url.lastPathComponent)")
        } catch {
            print("Error loading preview: \(error)")
            self.errorMessage = "Failed to load image preview."
        }
    }
}

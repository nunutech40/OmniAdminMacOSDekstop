//
//  AddProjectInlineView.swift
//  OmniAdmin
//
//  Created by Nunu Nugraha on 27/12/25.
//

import SwiftUI

struct AddProjectInlineView: View {
    @Binding var isAdding: Bool
    var onComplete: () -> Void
    
    // State sesuai CreatePortfolioDTO di Vapor lo
    @State private var title = ""
    @State private var shortDesc = ""
    @State private var description = ""
    @State private var category = "macOS App"
    @State private var linkGithub = ""
    @State private var linkDemo = ""
    @State private var isHero = false
    
    // State buat Tech Stack
    @State private var masterTechs: [TechStack] = []
    @State private var selectedTechIDs: Set<UUID> = []
    @State private var newTechName = "" // Buat nambah tech baru langsung
    
    @State private var isSaving = false
    
    private let portfolioRepo = Injection.shared.providePortfolioRepository()
    private let techRepo = Injection.shared.provideTechRepository()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            Text("Create New Project")
                .font(.system(size: 28, weight: .bold))
                .padding(.bottom, 20)
            
            Form {
                Section("Core Information") {
                    TextField("Project Title", text: $title)
                    TextField("Short Description", text: $shortDesc)
                    Picker("Category", selection: $category) {
                        ForEach(["macOS App", "iOS App", "Web", "Networking"], id: \.self) { Text($0) }
                    }
                }
                
                Section("Links") {
                    TextField("GitHub URL", text: $linkGithub)
                    TextField("Demo / Store URL", text: $linkDemo)
                }
                
                Section("Detailed Description") {
                    TextEditor(text: $description)
                        .frame(height: 80)
                }
                
                Section("Tech Stack (Pilih atau Tambah Baru)") {
                    // Fitur nambah tech stack kalau master data kosong
                    HStack {
                        TextField("New tech name...", text: $newTechName)
                        Button {
                            createTech()
                        } label: {
                            Image(systemName: "plus.circle.fill")
                        }
                        .disabled(newTechName.isEmpty)
                    }
                    
                    Divider()
                    
                    if masterTechs.isEmpty {
                        Text("No master techs. Add one above.").italic().font(.caption)
                    } else {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 90))], spacing: 8) {
                            ForEach(masterTechs) { tech in
                                let isSelected = selectedTechIDs.contains(tech.id)
                                Text(tech.name)
                                    .font(.caption)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(isSelected ? Color.accentColor : Color.gray.opacity(0.2))
                                    .cornerRadius(15)
                                    .onTapGesture {
                                        if isSelected { selectedTechIDs.remove(tech.id) }
                                        else { selectedTechIDs.insert(tech.id) }
                                    }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .formStyle(.grouped)
            
            // Footer Action
            HStack {
                Button("Cancel") { isAdding = false }
                    .buttonStyle(.plain)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if isSaving {
                    ProgressView().controlSize(.small)
                } else {
                    Button("Save Project") { save() }
                        .buttonStyle(.borderedProminent)
                        .disabled(title.isEmpty || shortDesc.isEmpty)
                }
            }
            .padding(.top, 20)
        }
        .padding(30)
        .task { await loadTechs() }
    }
    
    private func loadTechs() async {
        masterTechs = (try? await techRepo.fetchAllTechs()) ?? []
    }
    
    private func createTech() {
        Task {
            do {
                let new = try await techRepo.createTech(name: newTechName)
                masterTechs.append(new)
                selectedTechIDs.insert(new.id)
                newTechName = ""
            } catch { print(error) }
        }
    }
    
    private func save() {
        isSaving = true
        Task {
            do {
                // SINKRON SAMA PORTFOLIO CONTROLLER VAPOR
                _ = try await portfolioRepo.createProject(
                    title: title,
                    description: description,
                    link: linkGithub, // Bisa di-adjust mapping-nya di Repo
                    category: category,
                    techIDs: Array(selectedTechIDs)
                )
                onComplete()
                isAdding = false
            } catch {
                print("Error: \(error)")
                isSaving = false
            }
        }
    }
}

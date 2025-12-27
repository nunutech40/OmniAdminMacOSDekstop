//
//  ProjectEditorView.swift
//  OmniAdmin
//
//  Created by Nunu Nugraha on 25/12/25.
//

import SwiftUI

struct ProjectEditorView: View {
    @State private var viewModel: ProjectEditorViewModel
    
    init(project: Project) {
        _viewModel = State(initialValue: ProjectEditorViewModel(project: project))
    }
    
    var body: some View {
        @Bindable var viewModel = viewModel
        
        Form {
            Section("General Info") {
                TextField("Title", text: $viewModel.project.title)
                
                Picker("Category", selection: $viewModel.project.category) {
                    ForEach(["macOS App", "iOS App", "Web", "Networking"], id: \.self) {
                        Text($0)
                    }
                }
                
                TextEditor(text: $viewModel.project.description)
                    .frame(height: 100)
                    .font(.body)
            }
            
            Section("Tech Stack") {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        // FIX: Nama variabel diubah dari newTech menjadi newTechName
                        TextField("Tambah teknologi...", text: $viewModel.newTechName)
                            .textFieldStyle(.roundedBorder)
                            .onSubmit { viewModel.addTech() }
                        
                        Button(action: viewModel.addTech) {
                            Image(systemName: "plus.circle.fill")
                        }
                        .buttonStyle(.plain)
                        .disabled(viewModel.newTechName.isEmpty)
                    }
                    
                    // Menampilkan Chips berdasarkan teknologi yang dipilih (selectedTechIDs)
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 8) {
                        // Kita memfilter availableTechs yang ID-nya ada di selectedTechIDs
                        let selectedTechs = viewModel.availableTechs.filter {
                            viewModel.selectedTechIDs.contains($0.id)
                        }
                        
                        ForEach(selectedTechs) { tech in
                            HStack {
                                Text(tech.name).font(.caption).lineLimit(1)
                                Button {
                                    viewModel.selectedTechIDs.remove(tech.id)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.caption2)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.accentColor.opacity(0.15))
                            .cornerRadius(8)
                        }
                    }
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Edit \(viewModel.project.title)")
        .task {
            // Penting: Ambil data master saat view muncul
            await viewModel.loadMasterData()
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                if viewModel.isLoading {
                    ProgressView().controlSize(.small)
                } else {
                    Button("Save Changes") {
                        Task { await viewModel.saveChanges() }
                    }
                }
            }
        }
    }
}

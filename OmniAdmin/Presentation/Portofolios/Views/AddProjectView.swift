//
//  AddProjectView.swift
//  OmniAdmin
//
//  Created by Nunu Nugraha on 27/12/25.
//

import SwiftUI

struct AddProjectView: View {
    @Environment(\.dismiss) private var dismiss // Cara paling aman buat nutup modal
    @Binding var isPresented: Bool
    var onComplete: () -> Void
    @State private var viewModel: AddProjectViewModel

    init(isPresented: Binding<Bool>, projectToEdit: Project? = nil, onComplete: @escaping () -> Void) {
        self._isPresented = isPresented
        self.onComplete = onComplete
        self._viewModel = State(initialValue: AddProjectViewModel(projectToEdit: projectToEdit))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(viewModel.projectToEdit == nil ? "Create New Project" : "Edit Project")
                .font(.system(size: 28, weight: .bold)).padding(.bottom, 20)

            Form {
                Section("Core Information") {
                    TextField("Title", text: $viewModel.title)
                    TextField("Short Description", text: $viewModel.shortDesc)
                    Picker("Category", selection: $viewModel.category) {
                        ForEach(["macOS App", "iOS App", "Web", "Networking"], id: \.self) { Text($0) }
                    }
                    Toggle("Feature as Hero", isOn: $viewModel.isHero)
                }

                Section("Links & Media") {
                    TextField("GitHub URL", text: $viewModel.linkGithub)
                    TextField("Demo URL", text: $viewModel.linkDemo)
                    TextField("Store URL", text: $viewModel.linkStore)      // BARU
                    TextField("Thumbnail URL", text: $viewModel.thumbnailUrl) // BARU
                }

                Section("Detailed Description") {
                    TextEditor(text: $viewModel.description)
                        .frame(height: 100)
                }

                Section("Tech Stack") {
                    HStack {
                        TextField("New tech...", text: $viewModel.newTechName)
                            .onSubmit { Task { await viewModel.createTech() } }
                        Button { Task { await viewModel.createTech() } } label: { Image(systemName: "plus.circle.fill") }
                    }
                    techChipsGrid
                }
            }
            .formStyle(.grouped)
            .disabled(viewModel.isSaving)

            // FOOTER DENGAN LOGIC DISMISS YANG BENAR
            HStack {
                if viewModel.projectToEdit == nil {
                    Button("Cancel") { dismiss() }.buttonStyle(.plain)
                }
                Spacer()
                
                if viewModel.isSaving {
                    ProgressView().controlSize(.small).padding(.trailing, 10)
                }
                
                Button(viewModel.projectToEdit == nil ? "Save Project" : "Update Changes") {
                    handleSave()
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isSaving || viewModel.title.isEmpty)
            }
            .padding(.top, 20)
        }
        .padding(30)
        .task { await viewModel.loadTechs() }
    }

    // Logic penanganan save dan tutup halaman
    private func handleSave() {
        Task {
            let success = await viewModel.save()
            if success {
                onComplete() // Refresh list di dashboard
                dismiss()    // Tutup sheet
                isPresented = false // Backup untuk memastikan binding berubah
            }
        }
    }

    private var techChipsGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 90))], spacing: 8) {
            ForEach(viewModel.masterTechs) { tech in
                let isSelected = viewModel.selectedTechIDs.contains(tech.id)
                Text(tech.name)
                    .font(.caption).padding(8)
                    .background(isSelected ? Color.accentColor : Color.gray.opacity(0.2))
                    .foregroundColor(isSelected ? .white : .primary)
                    .cornerRadius(10)
                    .onTapGesture {
                        if isSelected { viewModel.selectedTechIDs.remove(tech.id) }
                        else { viewModel.selectedTechIDs.insert(tech.id) }
                    }
            }
        }
        .padding(.vertical, 10)
    }
}

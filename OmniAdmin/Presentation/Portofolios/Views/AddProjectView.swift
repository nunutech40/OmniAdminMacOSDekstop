//
//  AddProjectView.swift
//  OmniAdmin
//
//  Created by Nunu Nugraha on 27/12/25.
//

import SwiftUI

struct AddProjectView: View {
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
                Section("Information") {
                    TextField("Title", text: $viewModel.title)
                    TextField("Short Description", text: $viewModel.shortDesc)
                    Picker("Category", selection: $viewModel.category) {
                        ForEach(["macOS App", "iOS App", "Web", "Networking"], id: \.self) { Text($0) }
                    }
                    Toggle("Feature as Hero", isOn: $viewModel.isHero)
                }

                Section("Links") {
                    TextField("GitHub URL", text: $viewModel.linkGithub)
                    TextField("Demo URL", text: $viewModel.linkDemo)
                }

                Section("Tech Stack") {
                    HStack {
                        TextField("New tech...", text: $viewModel.newTechName)
                        Button { Task { await viewModel.createTech() } } label: { Image(systemName: "plus.circle.fill") }
                    }
                    techChipsGrid
                }
            }
            .formStyle(.grouped)
            .disabled(viewModel.isSaving) // Disable form saat loading

            // FOOTER DENGAN LOADING INDICATOR
            HStack {
                if viewModel.projectToEdit == nil {
                    Button("Cancel") { isPresented = false }.buttonStyle(.plain)
                }
                Spacer()
                
                if viewModel.isSaving {
                    ProgressView().controlSize(.small) // INI LOADINGNYA
                        .padding(.trailing, 10)
                }
                
                Button(viewModel.projectToEdit == nil ? "Save Project" : "Update Changes") {
                    Task {
                        await viewModel.save {
                            onComplete()
                            isPresented = false // INI YANG NUTUP HALAMAN
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isSaving || viewModel.title.isEmpty)
            }
            .padding(.top, 20)
        }
        .padding(30)
        .task { await viewModel.loadTechs() }
    }

    private var techChipsGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 90))], spacing: 8) {
            ForEach(viewModel.masterTechs) { tech in
                let isSelected = viewModel.selectedTechIDs.contains(tech.id)
                Text(tech.name)
                    .font(.caption).padding(8)
                    .background(isSelected ? Color.accentColor : Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .onTapGesture {
                        if isSelected { viewModel.selectedTechIDs.remove(tech.id) }
                        else { viewModel.selectedTechIDs.insert(tech.id) }
                    }
            }
        }
    }
}

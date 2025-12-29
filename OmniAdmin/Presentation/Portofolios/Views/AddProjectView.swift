//
//  AddProjectView.swift
//  OmniAdmin
//
//  Created by Nunu Nugraha on 27/12/25.
//

import SwiftUI

struct AddProjectView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var isPresented: Bool
    var onComplete: () -> Void
    @State private var viewModel: AddProjectViewModel

    init(isPresented: Binding<Bool>, projectToEdit: Project? = nil, onComplete: @escaping () -> Void) {
        self._isPresented = isPresented
        self.onComplete = onComplete
        self._viewModel = State(initialValue: AddProjectViewModel(projectToEdit: projectToEdit))
    }

    var body: some View {
        ZStack {
            mainContent
            
            if viewModel.isSaving {
                loadingOverlay
            }
        }
        .task { await viewModel.loadTechs() }
        .alert("Success", isPresented: $viewModel.showSuccessAlert) {
            successAlertButtons
        } message: {
            Text("Your project has been saved successfully to the database.")
        }
        .alert("Error", isPresented: errorAlertBinding) {
            Button("Got it") { }
        } message: {
            Text(viewModel.errorMessage ?? "Unknown error")
        }
    }
}

// MARK: - Subviews
private extension AddProjectView {
    
    private var mainContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerView
            
            projectForm
            
            footerView
        }
        .padding(30)
    }
    
    private var headerView: some View {
        Text(viewModel.projectToEdit == nil ? "Create New Project" : "Edit Project")
            .font(.system(size: 28, weight: .bold))
            .padding(.bottom, 20)
    }
    
    private var projectForm: some View {
        Form {
            coreInformationSection
            linksAndMediaSection
            detailedDescriptionSection
            techStackSection
        }
        .formStyle(.grouped)
    }
    
    // MARK: - Form Sections
    private var coreInformationSection: some View {
        Section("Core Information") {
            TextField("Title", text: $viewModel.title)
            TextField("Short Description", text: $viewModel.shortDesc)
            Picker("Category", selection: $viewModel.category) {
                ForEach(["macOS App", "iOS App", "Web", "Networking"], id: \.self) { Text($0) }
            }
            Toggle("Feature as Hero", isOn: $viewModel.isHero)
        }
    }
    
    private var linksAndMediaSection: some View {
        Section("Links & Media") {
            TextField("GitHub URL", text: $viewModel.linkGithub)
            TextField("Demo URL", text: $viewModel.linkDemo)
            TextField("Store URL", text: $viewModel.linkStore)
            TextField("Thumbnail URL", text: $viewModel.thumbnailUrl)
        }
    }
    
    private var detailedDescriptionSection: some View {
        Section("Detailed Description") {
            TextEditor(text: $viewModel.description)
                .frame(height: 100)
        }
    }
    
    private var techStackSection: some View {
        Section("Tech Stack") {
            HStack {
                TextField("New tech...", text: $viewModel.newTechName)
                    .onSubmit { Task { await viewModel.createTech() } }
                Button { Task { await viewModel.createTech() } } label: {
                    Image(systemName: "plus.circle.fill")
                }
            }
            techChipsGrid
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
    
    // MARK: - Footer & Overlays
    private var footerView: some View {
        HStack {
            if viewModel.projectToEdit == nil {
                Button("Cancel") { dismiss() }
                    .buttonStyle(.plain)
            }
            Spacer()
            
            Button(viewModel.projectToEdit == nil ? "Save Project" : "Update Changes") {
                Task { await viewModel.save() }
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isSaving || viewModel.title.isEmpty)
        }
        .padding(.top, 20)
    }
    
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.15)
                .edgesIgnoringSafeArea(.all)
            VStack(spacing: 12) {
                ProgressView()
                    .controlSize(.large)
                Text("Saving Project...").font(.caption).bold()
            }
            .padding(20)
            .background(.ultraThinMaterial)
            .cornerRadius(12)
        }
    }
    
    // MARK: - Helpers
    private var successAlertButtons: some View {
        Button("OK") {
            onComplete()
            dismiss()
        }
    }
    
    private var errorAlertBinding: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { _ in viewModel.errorMessage = nil }
        )
    }
}

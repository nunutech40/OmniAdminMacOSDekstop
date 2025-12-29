//
//  AddProjectView.swift
//  OmniAdmin
//
//  Created by Nunu Nugraha on 27/12/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct AddProjectView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var isPresented: Bool
    var onComplete: () -> Void
    @State private var viewModel: AddProjectViewModel
    @State private var showFilePicker = false
    
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
        .fileImporter(
            isPresented: $showFilePicker,
            allowedContentTypes: [.image],
            onCompletion: { result in
                if case .success(let url) = result {
                    viewModel.handleImageSelection(url: url)
                }
            }
        )
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
                .onChange(of: viewModel.title) { oldValue, newValue in
                    if newValue.count > 50 {
                        viewModel.title = String(newValue.prefix(50))
                    }
                }
            
            // SHORT DESC VALIDATION
            TextField("Short Description", text: $viewModel.shortDesc)
                .onChange(of: viewModel.shortDesc) { oldValue, newValue in
                    if newValue.count > 120 {
                        viewModel.shortDesc = String(newValue.prefix(120))
                    }
                }
            Picker("Category", selection: $viewModel.category) {
                ForEach(["macOS App", "iOS App", "Web", "Networking"], id: \.self) { Text($0) }
            }
            Toggle("Feature as Hero", isOn: $viewModel.isHero)
        }
    }
    
    private var linksAndMediaSection: some View {
        Section("Links & Media") {
            VStack(alignment: .leading) {
                Text("Thumbnail Image").font(.caption).foregroundColor(.secondary)
                
                Button {
                    showFilePicker = true
                } label: {
                    Group {
                        if let image = viewModel.previewImage {
                            // 1. Tampilkan Gambar Lokal (yang baru di-browse)
                            Image(nsImage: image)
                                .resizable()
                        } else if !viewModel.thumbnailUrl.isEmpty {
                            // 2. Tampilkan Gambar dari Server (untuk Edit mode)
                            AsyncImage(url: URL(string: "http://157.10.161.215:8080\(viewModel.thumbnailUrl)")) { img in
                                img.resizable()
                            } placeholder: {
                                ProgressView()
                            }
                        } else {
                            // 3. Placeholder jika benar-benar kosong
                            ZStack {
                                RoundedRectangle(cornerRadius: 8).fill(Color.gray.opacity(0.1))
                                VStack {
                                    Image(systemName: "photo.badge.plus").font(.largeTitle)
                                    Text("Click to Browse Image")
                                }.foregroundColor(.gray)
                            }
                        }
                    }
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 150)
                    .cornerRadius(8)
                    .clipped() // Agar gambar nggak keluar dari frame
                }
                .buttonStyle(.plain)
            }
            
            TextField("GitHub URL", text: $viewModel.linkGithub)
            TextField("Demo URL", text: $viewModel.linkDemo)
            TextField("Store URL", text: $viewModel.linkStore)
        }
    }
    
    private var detailedDescriptionSection: some View {
        Section("Detailed Description") {
            ZStack(alignment: .topLeading) {
                if viewModel.description.isEmpty {
                    Text("Write something amazing...")
                        .foregroundColor(.gray.opacity(0.5))
                        .padding(.top, 8)
                        .padding(.leading, 5)
                }
                
                TextEditor(text: $viewModel.description)
                    .frame(minHeight: 100)
                    .scrollContentBackground(.hidden) // Biar background-nya transparan/ikut Form
                    .padding(.horizontal, -5) // Adjust alignment agar lurus dengan label lain
            }
        }
    }
    
    private var techStackSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                // Input Field yang lebih rapi
                HStack {
                    TextField("New tech (e.g. Docker, Combine)...", text: $viewModel.newTechName)
                        .textFieldStyle(.plain)
                        .onSubmit { Task { await viewModel.createTech() } }
                    
                    Button {
                        Task { await viewModel.createTech() }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                            .font(.title2)
                    }
                    .buttonStyle(.plain)
                    .disabled(viewModel.newTechName.isEmpty)
                }
                .padding(10)
                .background(Color(NSColor.controlBackgroundColor)) // Background halus
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                
                // Chips Grid menggunakan FlowLayout
                techChipsGrid
            }
            .padding(.vertical, 4)
        } header: {
            Text("Tech Stack").font(.headline)
        }
    }
    
    private var techChipsGrid: some View {
        FlowLayout(spacing: 8) {
            ForEach(viewModel.masterTechs) { tech in
                let isSelected = viewModel.selectedTechIDs.contains(tech.id)
                
                HStack(spacing: 4) {
                    Text(tech.name)
                    if isSelected {
                        Image(systemName: "checkmark").font(.system(size: 10, weight: .bold))
                    }
                }
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.accentColor : Color.gray.opacity(0.15))
                )
                .foregroundColor(isSelected ? .white : .primary)
                // Animasi halus saat ditekan
                .scaleEffect(isSelected ? 1.05 : 1.0)
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        if isSelected { viewModel.selectedTechIDs.remove(tech.id) }
                        else { viewModel.selectedTechIDs.insert(tech.id) }
                    }
                }
            }
        }
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

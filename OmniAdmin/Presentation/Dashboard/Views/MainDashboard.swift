//
//  MainDashboard.swift
//  OmniAdmin
//
//  Created by Nunu Nugraha on 25/12/25.
//
import SwiftUI

// MARK: - Admin Module Enum
enum AdminModule: Hashable {
    case portfolios
    case settings
}

struct MainDashboard: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var viewModel = MainDashboardViewModel()
    
    @State private var columnVisibility = NavigationSplitViewVisibility.all
    @State private var selectedModule: AdminModule? = .portfolios
    @State private var selectedProjectID: UUID?
    @State private var searchText: String = ""
    
    // Flag untuk trigger Sheet (Mode Tambah)
    @State private var isAddingNewProject = false
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            // MARK: - KOLOM 1: SIDEBAR
            sidebarContent
                .navigationSplitViewColumnWidth(min: 200, ideal: 250)
            
        } content: {
            // MARK: - KOLOM 2: LIST (Kolom Tengah)
            VStack {
                switch selectedModule {
                case .portfolios:
                    PortfolioListView(projects: filteredProjects, selectedID: $selectedProjectID)
                        .onChange(of: selectedProjectID) { _, newValue in
                            // Kalau user pilih project di list, tutup mode "Tambah"
                            if newValue != nil { isAddingNewProject = false }
                        }
                case .settings:
                    settingsView
                case .none:
                    Text("Select a module")
                }
            }
            .navigationSplitViewColumnWidth(min: 350, ideal: 400)
            .navigationTitle("OmniAdmin")
            .searchable(text: $searchText, placement: .toolbar, prompt: "Search project...")
            
        } detail: {
            // MARK: - KOLOM 3: DETAIL (Unified Editor)
            Group {
                if let projectID = selectedProjectID,
                   let project = viewModel.projects.first(where: { $0.id == projectID }) {
                    
                    // MODE EDIT: Kirim projectToEdit, isPresented pake constant true
                    AddProjectView(
                        isPresented: .constant(true),
                        projectToEdit: project
                    ) {
                        Task { await viewModel.loadProjects() }
                    }
                    .id(project.id) // Paksa refresh view saat ganti pilihan project
                    
                } else {
                    ContentUnavailableView(
                        "No Project Selected",
                        systemImage: "doc.text.magnifyingglass",
                        description: Text("Silahkan pilih project di kolom tengah atau klik + untuk menambah.")
                    )
                }
            }
        }
        // MARK: - SHEET: MODE TAMBAH
        .sheet(isPresented: $isAddingNewProject) {
            // MODE TAMBAH: projectToEdit di-set nil
            AddProjectView(
                isPresented: $isAddingNewProject,
                projectToEdit: nil
            ) {
                Task { await viewModel.loadProjects() }
            }
            .frame(minWidth: 550, minHeight: 650)
        }
        // MARK: - TOOLBAR
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    selectedProjectID = nil // Reset pilihan list
                    isAddingNewProject = true // Buka sheet tambah
                } label: {
                    Image(systemName: "plus")
                }
                .help("Add New Project")
            }
        }
        // WINDOW SPECS
        .frame(minWidth: 1000, minHeight: 650)
        .task {
            await viewModel.loadProjects()
        }
    }
    
    // MARK: - Logic Helpers
    var filteredProjects: [Project] {
        if searchText.isEmpty {
            return viewModel.projects
        } else {
            return viewModel.projects.filter {
                $0.title.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    // MARK: - Sidebar Component
    private var sidebarContent: some View {
        List(selection: $selectedModule) {
            Section("Management") {
                NavigationLink(value: AdminModule.portfolios) {
                    Label("Portfolios", systemImage: "briefcase.fill")
                }
            }
            Section("System") {
                NavigationLink(value: AdminModule.settings) {
                    Label("Settings", systemImage: "gearshape.fill")
                }
            }
        }
        .listStyle(.sidebar)
    }
    
    // MARK: - Settings Component
    private var settingsView: some View {
        Form {
            Section("User Profile") {
                LabeledContent("Username", value: authManager.currentUser?.username ?? "-")
                LabeledContent("Role", value: authManager.currentUser?.role ?? "Admin")
            }
            Section {
                Button(role: .destructive) {
                    authManager.logout()
                } label: {
                    Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                }
            }
        }
        .formStyle(.grouped)
    }
}

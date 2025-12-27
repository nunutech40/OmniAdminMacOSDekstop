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
    
    // Flag buat nentuin apakah kolom kanan nampilin Form Tambah atau Editor
    @State private var isAddingNewProject = false
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            // KOLOM 1: SIDEBAR
            sidebarContent
        } content: {
            // KOLOM 2: LIST (Kolom Tengah)
            VStack {
                switch selectedModule {
                case .portfolios:
                    PortfolioListView(projects: filteredProjects, selectedID: $selectedProjectID)
                        // Saat pilih project, mode "Tambah" dimatiin biar gak bentrok
                        .onChange(of: selectedProjectID) { _, newValue in
                            if newValue != nil { isAddingNewProject = false }
                        }
                case .settings:
                    settingsView
                case .none:
                    Text("Select a module")
                }
            }
            // --- UKURAN TETEP SESUAI REQUEST LO (350 - 400) ---
            .navigationSplitViewColumnWidth(min: 350, ideal: 400)
            .navigationTitle("OmniAdmin")
            // Searchable ditaruh di sini agar muncul di kolom tengah
            .searchable(text: $searchText, placement: .toolbar, prompt: "Search...")
            
        } detail: {
            // KOLOM 3: DETAIL/EDITOR (Kolom Kanan)
            Group {
                if isAddingNewProject {
                    // Tampilan Form Tambah (Bukan Modal)
                    AddProjectInlineView(isAdding: $isAddingNewProject) {
                        Task { await viewModel.loadProjects() }
                    }
                } else if let projectID = selectedProjectID,
                          let project = viewModel.projects.first(where: { $0.id == projectID }) {
                    // Tampilan Editor
                    ProjectEditorView(project: project)
                } else {
                    ContentUnavailableView(
                        "No Project Selected",
                        systemImage: "doc.text.magnifyingglass",
                        description: Text("Silahkan pilih project atau klik + untuk menambah.")
                    )
                }
            }
        }
        // --- INI SOLUSI KLIK & DOUBLE PLUS ---
        // Pindahin .toolbar ke level Root (NavigationSplitView)
        // Ini memastikan tombol cuma SATU dan aksi Klik-nya 100% jalan.
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    print("Plus Button Clicked!") // Cek di console Xcode lo
                    selectedProjectID = nil // Deselect project lama
                    isAddingNewProject = true // Trigger form di kolom kanan
                } label: {
                    Image(systemName: "plus")
                }
                .help("Add New Project")
            }
        }
        // UKURAN WINDOW UTAMA TETEP 1000x650
        .frame(minWidth: 1000, minHeight: 650)
        .task {
            await viewModel.loadProjects()
        }
    }
    
    var filteredProjects: [Project] {
        searchText.isEmpty ? viewModel.projects : viewModel.projects.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }
    
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
        .navigationSplitViewColumnWidth(min: 200, ideal: 250)
        .listStyle(.sidebar)
        // Hapus .navigationTitle di sini biar gak bikin toolbar double
    }
    
    private var settingsView: some View {
        Form {
            Section("User Profile") {
                LabeledContent("Username", value: authManager.currentUser?.username ?? "-")
                LabeledContent("Role", value: authManager.currentUser?.role ?? "Admin")
            }
            Section {
                Button(role: .destructive) { authManager.logout() } label: {
                    Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                }
            }
        }
        .formStyle(.grouped)
    }
}

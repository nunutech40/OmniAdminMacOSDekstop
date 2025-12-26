//
//  MainDashboard.swift
//  OmniAdmin
//
//  Created by Nunu Nugraha on 25/12/25.
//
//
//  MainDashboard.swift
//  OmniAdmin
//
//  Created by Nunu Nugraha on 25/12/25.
//

import SwiftUI

enum AdminModule: Hashable {
    case portfolios
    case settings
}

struct MainDashboard: View {
    // 1. Hubungkan ke AuthManager buat dapet akses Logout & Profile
    @EnvironmentObject var authManager: AuthenticationManager
    
    @State private var selectedModule: AdminModule? = .portfolios
    @State private var selectedProjectID: UUID?
    @State private var searchText: String = ""
    
    // Pakai Project (sesuai Model), bukan PortfolioProject
    @State private var projects = mockProjects

    var body: some View {
        NavigationSplitView {
            // KOLOM 1: SIDEBAR
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
            .navigationTitle("OmniAdmin")
            
        } content: {
            // KOLOM 2: LIST (TABLE)
            Group {
                switch selectedModule {
                case .portfolios:
                    PortfolioListView(projects: filteredProjects, selectedID: $selectedProjectID)
                        .searchable(text: $searchText, placement: .toolbar, prompt: "Search projects...")
                case .settings:
                    // 2. Di sini lo bisa taruh info user & tombol Logout
                    settingsView
                case .none:
                    Text("Select a module")
                }
            }
        } detail: {
            // KOLOM 3: EDITOR
            if let projectID = selectedProjectID,
               let project = projects.first(where: { $0.id == projectID }) {
                ProjectEditorView(project: project)
            } else {
                ContentUnavailableView("No Project Selected", systemImage: "doc.text.magnifyingglass")
            }
        }
        .frame(minWidth: 900, minHeight: 600)
    }
    
    var filteredProjects: [Project] {
        searchText.isEmpty ? projects : projects.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }
    
    // 3. View Settings simpel biar gak ngerusak layout utama
    private var settingsView: some View {
        Form {
            Section("User Profile") {
                LabeledContent("Username", value: authManager.currentUser?.username ?? "-")
                LabeledContent("Role", value: authManager.currentUser?.role ?? "-")
            }
            
            Section {
                Button("Logout", role: .destructive) {
                    authManager.logout() // Panggil fungsi logout dari manager lo
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Settings")
    }
}

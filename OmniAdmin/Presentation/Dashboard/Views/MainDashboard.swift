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

// MARK: - Admin Module Enum
enum AdminModule: Hashable {
    case portfolios
    case settings
}

struct MainDashboard: View {
    // 1. Dependencies
    @EnvironmentObject var authManager: AuthenticationManager
    
    // 2. State Management (Sesuai request lo, tetep pake mock dulu)
    @State private var columnVisibility = NavigationSplitViewVisibility.all
    @State private var selectedModule: AdminModule? = .portfolios
    @State private var selectedProjectID: UUID?
    @State private var searchText: String = ""
    
    // Pakai data dummy lo dulu
    @State private var projects = mockProjects

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
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
            .navigationSplitViewColumnWidth(min: 200, ideal: 250)
            .listStyle(.sidebar)
            .navigationTitle("OmniAdmin")
            
        } content: {
            // KOLOM 2: LIST (TABLE)
            VStack {
                switch selectedModule {
                case .portfolios:
                    PortfolioListView(projects: filteredProjects, selectedID: $selectedProjectID)
                        .searchable(text: $searchText, placement: .toolbar, prompt: "Search projects...")
                case .settings:
                    settingsView
                case .none:
                    Text("Select a module")
                        .foregroundColor(.secondary)
                }
            }
            .navigationSplitViewColumnWidth(min: 350, ideal: 400)
            
        } detail: {
            // KOLOM 3: EDITOR
            if let projectID = selectedProjectID,
               let project = projects.first(where: { $0.id == projectID }) {
                ProjectEditorView(project: project)
            } else {
                ContentUnavailableView(
                    "No Project Selected",
                    systemImage: "doc.text.magnifyingglass",
                    description: Text("Silahkan pilih project di kolom tengah.")
                )
            }
        }
        // Kunci frame biar window dashboard lo gagah (min 1000px)
        .frame(minWidth: 1000, minHeight: 650)
    }
    
    // MARK: - Logic Helpers
    var filteredProjects: [Project] {
        searchText.isEmpty ? projects : projects.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }
    
    // MARK: - Settings View
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
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text("Logout")
                    }
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Settings")
    }
}

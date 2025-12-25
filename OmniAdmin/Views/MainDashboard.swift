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
    @State private var selectedModule: AdminModule? = .portfolios
    @State private var selectedProjectID: UUID?
    @State private var searchText: String = ""
    
    // Pakai Project (sesuai Model), bukan PortfolioProject
    @State private var projects = mockProjects

    var body: some View {
        NavigationSplitView {
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
            Group {
                switch selectedModule {
                case .portfolios:
                    // Passing filteredProjects ke ListView
                    PortfolioListView(projects: filteredProjects, selectedID: $selectedProjectID)
                        .searchable(text: $searchText, placement: .toolbar, prompt: "Search projects...")
                case .settings:
                    Text("Settings View").navigationTitle("Settings")
                case .none:
                    Text("Select a module")
                }
            }
        } detail: {
            if let projectID = selectedProjectID,
               let project = projects.first(where: { $0.id == projectID }) {
                ProjectEditorView(project: project) // Sekarang passing object Project
            } else {
                ContentUnavailableView("No Project Selected", systemImage: "doc.text.magnifyingglass")
            }
        }
        .frame(minWidth: 900, minHeight: 600)
    }
    
    var filteredProjects: [Project] {
        searchText.isEmpty ? projects : projects.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }
}

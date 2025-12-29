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
    
    // UI States
    @State private var selectedModule: AdminModule? = .portfolios
    @State private var searchText: String = ""
    @State private var isAddingNewProject = false
    @State private var projectToEdit: Project? // Untuk trigger Edit Sheet
    
    // Base URL Server lo
    private let serverBaseURL = "http://157.10.161.215:8080"

    var body: some View {
        NavigationSplitView {
            // MARK: - KOLOM 1: SIDEBAR
            sidebarContent
                .navigationSplitViewColumnWidth(min: 200, ideal: 250)
        } detail: {
            // MARK: - KOLOM 2: DYNAMIC CONTENT
            VStack(spacing: 0) {
                switch selectedModule {
                case .portfolios:
                    portfolioManagementArea
                case .settings:
                    settingsView
                case .none:
                    ContentUnavailableView("Select a Module", systemImage: "square.grid.2x2")
                }
            }
            .navigationTitle(selectedModule == .portfolios ? "Portfolio Management" : "Settings")
            .toolbar { toolbarContent }
        }
        // MARK: - SHEETS (Add & Edit)
        .sheet(isPresented: $isAddingNewProject) {
            AddProjectView(isPresented: $isAddingNewProject) {
                Task { await viewModel.loadProjects() }
            }
            .frame(minWidth: 600, minHeight: 700)
        }
        .sheet(item: $projectToEdit) { project in
            AddProjectView(isPresented: .constant(true), projectToEdit: project) {
                Task { await viewModel.loadProjects() }
            }
            .frame(minWidth: 600, minHeight: 700)
        }
        .task { await viewModel.loadProjects() }
    }
}

// MARK: - Subviews: Portfolio Area
private extension MainDashboard {
    
    var portfolioManagementArea: some View {
        VStack(spacing: 0) {
            // Header Stats Ringkas (Lead Dev Touch)
            HStack {
                Text("\(filteredProjects.count) Projects Total")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            
            Divider()
            
            // THE RICH TABLE
            Table(filteredProjects) {
                // 1. Preview
                TableColumn("Preview") { project in
                    AsyncImage(url: URL(string: serverBaseURL + (project.thumbnailUrl ?? ""))) { img in
                        img.resizable().aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.gray.opacity(0.1)
                    }
                    .frame(width: 32, height: 32)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                .width(40)

                // 2. Info Utama
                TableColumn("Project") { project in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(project.title).font(.body).bold()
                        Text(project.category ?? "Uncategorized").font(.caption2).foregroundColor(.secondary)
                    }
                }

                // 3. Hero Indicator
                TableColumn("Hero") { project in
                    Image(systemName: project.isHero ? "star.fill" : "star")
                        .foregroundColor(project.isHero ? .yellow : .gray.opacity(0.3))
                }
                .width(40)

                // 4. Tech Stack Count
                TableColumn("Techs") { project in
                    Text("\(project.techStacks?.count ?? 0)")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .background(Capsule().fill(Color.accentColor.opacity(0.1)))
                }
                .width(50)

                // 5. Links Status
                TableColumn("Links") { project in
                    HStack(spacing: 8) {
                        LinkIcon(systemName: "link", isActive: !(project.linkGithub ?? "").isEmpty)
                        LinkIcon(systemName: "safari", isActive: !(project.linkDemo ?? "").isEmpty)
                        LinkIcon(systemName: "bag", isActive: !(project.linkStore ?? "").isEmpty)
                    }
                }
                .width(80)

                // 6. Actions
                TableColumn("Actions") { project in
                    HStack {
                        Button { projectToEdit = project } label: {
                            Image(systemName: "pencil.circle.fill")
                                .foregroundColor(.accentColor)
                        }
                        .buttonStyle(.plain)
                        
                        Button(role: .destructive) {
                            // Action delete taruh sini
                        } label: {
                            Image(systemName: "trash.fill")
                        }
                        .buttonStyle(.plain)
                        .foregroundColor(.red)
                    }
                }
                .width(60)
            }
            .tableStyle(.inset)
        }
        .searchable(text: $searchText, placement: .toolbar, prompt: "Search by title...")
    }

    // Helper Link Icon
    func LinkIcon(systemName: String, isActive: Bool) -> some View {
        Image(systemName: systemName)
            .font(.caption)
            .foregroundColor(isActive ? .primary : .gray.opacity(0.2))
    }
}

// MARK: - Common Components
private extension MainDashboard {
    var sidebarContent: some View {
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
    
    var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .primaryAction) {
            Button {
                isAddingNewProject = true
            } label: {
                Image(systemName: "plus")
            }
        }
    }
    
    var settingsView: some View {
        Form {
            Section("User Information") {
                LabeledContent("Logged as", value: authManager.currentUser?.username ?? "-")
                LabeledContent("Server", value: "Production - Jakarta")
            }
            Button("Logout", role: .destructive) { authManager.logout() }
        }
        .formStyle(.grouped)
    }

    var filteredProjects: [Project] {
        if searchText.isEmpty { return viewModel.projects }
        return viewModel.projects.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }
}

//
//  PortfolioListView.swift
//  OmniAdmin
//
//  Created by Nunu Nugraha on 25/12/25.
//

import SwiftUI

struct PortfolioListView: View {
    let projects: [Project] // Terima data hasil filter dari Dashboard
    @Binding var selectedID: UUID?
    @State private var sortOrder = [KeyPathComparator(\Project.title)]
    @State private var sortedProjects: [Project] = []

    var body: some View {
        Table(sortedProjects, selection: $selectedID, sortOrder: $sortOrder) {
            TableColumn("Title", value: \.title)
            TableColumn("Category", value: \.category)
            TableColumn("Hero") { project in
                Image(systemName: project.isHero ? "star.fill" : "star")
                    .foregroundColor(project.isHero ? .yellow : .secondary)
            }
            .width(50)
        }
        // Update tampilan saat data dari parent atau sort order berubah
        .onAppear { sortedProjects = projects }
        .onChange(of: projects) { sortedProjects = projects.sorted(using: sortOrder) }
        .onChange(of: sortOrder) { sortedProjects.sort(using: $1) }
        .toolbar {
            Button(action: {}) { Label("Add Project", systemImage: "plus") }
        }
    }
}

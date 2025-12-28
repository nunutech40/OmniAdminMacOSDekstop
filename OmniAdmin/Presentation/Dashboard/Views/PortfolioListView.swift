//
//  PortfolioListView.swift
//  OmniAdmin
//
//  Created by Nunu Nugraha on 25/12/25.
//

import SwiftUI

struct PortfolioListView: View {
    let projects: [Project]
    @Binding var selectedID: UUID?
    @State private var sortOrder = [KeyPathComparator(\Project.title)]
    @State private var sortedProjects: [Project] = []

    var body: some View {
        Table(sortedProjects, selection: $selectedID, sortOrder: $sortOrder) {
            // Kolom ini aman karena Title bukan optional
            TableColumn("Title", value: \.title)
            
            // FIX: Jangan pake 'value:', pake closure buat handle optional category
            TableColumn("Category") { project in
                Text(project.category ?? "-")
            }
            
            TableColumn("Hero") { project in
                Image(systemName: project.isHero ? "star.fill" : "star")
                    .foregroundColor(project.isHero ? .yellow : .secondary)
            }
            .width(50)
        }
        // Update data saat data baru masuk
        .onChange(of: projects, initial: true) { _, newValue in
            sortedProjects = newValue.sorted(using: sortOrder)
        }
        // Update saat user klik header table buat sort
        .onChange(of: sortOrder) { _, newOrder in
            sortedProjects.sort(using: newOrder)
        }
    }
}

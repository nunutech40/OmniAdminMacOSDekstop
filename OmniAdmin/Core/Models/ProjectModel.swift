//
//  ProjectModel.swift
//  OmniAdmin
//
//  Created by Nunu Nugraha on 25/12/25.
//

import Foundation

struct Project: Identifiable, Hashable {
    let id: UUID
    var title: String
    var category: String
    var isHero: Bool
    var description: String
}

// Data dummy buat ngetes UI
let mockProjects = [
    Project(id: UUID(), title: "OmniAdmin", category: "macOS App", isHero: true, description: "The ecosystem controller."),
    Project(id: UUID(), title: "Bookmarker", category: "iOS App", isHero: false, description: "Track your reading list."),
    Project(id: UUID(), title: "Postie", category: "Networking Tool", isHero: true, description: "API testing simplified.")
]

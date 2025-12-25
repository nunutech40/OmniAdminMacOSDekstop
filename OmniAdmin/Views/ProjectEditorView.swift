//
//  ProjectEditorView.swift
//  OmniAdmin
//
//  Created by Nunu Nugraha on 25/12/25.
//

import SwiftUI

struct ProjectEditorView: View {
    let project: Project // Nerima object Project utuh
    
    var body: some View {
        Form {
            Section("Project Details") {
                TextField("Title", text: .constant(project.title))
                TextField("Category", text: .constant(project.category))
            }
            
            Section("Description") {
                TextEditor(text: .constant(project.description))
                    .frame(minHeight: 150)
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Edit Project")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { /* Save logic */ }
            }
        }
    }
}

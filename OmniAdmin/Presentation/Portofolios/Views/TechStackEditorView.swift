//
//  TechStackEditorView.swift
//  OmniAdmin
//
//  Created by Nunu Nugraha on 27/12/25.
//

import SwiftUI

struct TechStackEditorView: View {
    @Binding var techStack: [String]
    @State private var newTech: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Input Area
            HStack {
                TextField("Tambah tech (e.g. Vapor, SwiftData)...", text: $newTech)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit { addTech() } // Tekan enter buat nambah
                
                Button(action: addTech) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(.blue)
                }
                .buttonStyle(.plain)
                .disabled(newTech.isEmpty)
            }
            
            // Chips Area (Flow Layout)
            // Menggunakan Wrapping HStack sederhana
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(techStack, id: \.self) { tech in
                        TechTag(name: tech) {
                            withAnimation {
                                techStack.removeAll { $0 == tech }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func addTech() {
        let trimmed = newTech.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty && !techStack.contains(trimmed) {
            withAnimation {
                techStack.append(trimmed)
                newTech = ""
            }
        }
    }
}

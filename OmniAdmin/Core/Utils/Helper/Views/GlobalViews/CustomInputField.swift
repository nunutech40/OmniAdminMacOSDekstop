//
//  CustomInputField.swift
//  OmniAdmin
//
//  Created by Nunu Nugraha on 27/12/25.
//
import SwiftUI

// MARK: - Reusable Components
struct CustomInputField: View {
    let title: String
    @Binding var text: String
    let hint: String
    var isSecure: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
            
            if isSecure {
                SecureField(hint, text: $text)
                    .textFieldStyle(.roundedBorder)
            } else {
                TextField(hint, text: $text)
                    .textFieldStyle(.roundedBorder)
            }
        }
    }
}

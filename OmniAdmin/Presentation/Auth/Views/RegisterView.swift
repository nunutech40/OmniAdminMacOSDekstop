//
//  RegisterView.swift
//  OmniAdmin
//
//  Created by Nunu Nugraha on 27/12/25.
//

import SwiftUI

struct RegisterView: View {
    // MARK: - Properties
    var viewModel: RegisterViewModel
    var onBackToLoginTapped: () -> Void
    
    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    // MARK: - Validation Logic
    private var canSubmit: Bool {
        username.isValidUsername &&
        password.isValidPassword &&
        password == confirmPassword &&
        !viewModel.isLoading
    }

    // MARK: - Main Body
    var body: some View {
        ZStack {
            backgroundLayer
            
            VStack(spacing: 30) {
                headerSection
                inputFormSection
                actionSection
            }
            .padding(40)
        }
        .frame(width: 400, height: 530)
        .onChange(of: viewModel.isSuccess) { _, success in
            if success { onBackToLoginTapped() }
        }
    }
}

// MARK: - View Sections
private extension RegisterView {
    
    private var backgroundLayer: some View {
        Color(NSColor.windowBackgroundColor)
            .ignoresSafeArea()
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.badge.plus.fill")
                .font(.system(size: 50))
                .foregroundStyle(.green)
            
            Text("Create Admin Account")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Register a new administrator for OmniAdmin")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    private var inputFormSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            CustomInputField(title: "Username", text: $username, hint: "min. 4 karakter")
            
            CustomInputField(title: "Password", text: $password, hint: "min. 8 karakter", isSecure: true)
            
            CustomInputField(title: "Confirm Password", text: $confirmPassword, hint: "Password harus cocok", isSecure: true)
            
            // Error Message Area
            if viewModel.isError {
                Text(viewModel.errorMessage)
                    .font(.caption2)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .frame(width: 280)
    }
    
    private var actionSection: some View {
        VStack(spacing: 12) {
            if viewModel.isLoading {
                ProgressView()
                    .controlSize(.small)
            } else {
                Button(action: {
                    Task { await viewModel.register(username: username, pass: password) }
                }) {
                    Text("Register Now")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(canSubmit ? .green : .gray)
                .disabled(!canSubmit)
                
                Button("Back to Login") {
                    onBackToLoginTapped()
                }
                .buttonStyle(.plain)
                .foregroundStyle(.blue)
                .font(.subheadline)
            }
        }
        .frame(width: 280)
    }
}



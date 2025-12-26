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
    
    // Samakan dengan LoginView (260px) biar konsisten secara visual
    private let componentWidth: CGFloat = 260
    
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
            
            VStack(spacing: 35) {
                headerSection
                inputFormSection
                actionSection
            }
            .padding(40)
        }
        .frame(width: 400, height: 550)
        .onChange(of: viewModel.isSuccess) { _, success in
            if success { onBackToLoginTapped() }
        }
    }
}

// MARK: - View Sections
private extension RegisterView {
    
    private var backgroundLayer: some View {
        // Efek Glassmorphism khas macOS
        VisualEffectView(material: .underWindowBackground, blendingMode: .behindWindow)
            .ignoresSafeArea()
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.badge.plus.fill")
                .font(.system(size: 55))
                .foregroundStyle(.linearGradient(colors: [.green, .teal], startPoint: .top, endPoint: .bottom))
            
            Text("Create Account")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            Text("Join the OmniAdmin network")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    private var inputFormSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            CustomInputField(title: "Username", text: $username, hint: "min. 4 karakter")
            
            CustomInputField(title: "Password", text: $password, hint: "min. 8 karakter", isSecure: true)
            
            CustomInputField(title: "Confirm Password", text: $confirmPassword, hint: "Password harus cocok", isSecure: true)
            
            if viewModel.isError {
                Text(viewModel.errorMessage)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.red)
                    .frame(width: componentWidth, alignment: .center)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .frame(width: componentWidth)
    }
    
    private var actionSection: some View {
        VStack(spacing: 15) {
            if viewModel.isLoading {
                ProgressView()
                    .controlSize(.small)
                    .frame(width: componentWidth, height: 32)
            } else {
                Button(action: {
                    Task { await viewModel.register(username: username, pass: password) }
                }) {
                    Text("Register Now")
                        .fontWeight(.semibold)
                        .frame(width: componentWidth, height: 20)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(canSubmit ? .green : .secondary)
                .disabled(!canSubmit)
                
                Button("Back to Login") {
                    onBackToLoginTapped()
                }
                .buttonStyle(.plain)
                .foregroundStyle(.blue)
                .font(.subheadline)
            }
        }
    }
}

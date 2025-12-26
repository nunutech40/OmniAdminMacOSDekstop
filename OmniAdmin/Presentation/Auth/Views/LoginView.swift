//
//  LoginView.swift
//  OmniAdmin
//
//  Created by Nunu Nugraha on 25/12/25.
//

import SwiftUI

struct LoginView: View {
    var viewModel: LoginViewModel
    @EnvironmentObject var authManager: AuthenticationManager
    var onSignUpTapped: () -> Void
    
    @State private var email = ""
    @State private var password = ""
    
    // 1. Tentukan konstanta lebar biar simetris kabeh
    private let componentWidth: CGFloat = 260

    var canSubmit: Bool {
        (email.isValidEmail || email.isValidUsername) &&
        password.isValidPassword &&
        !viewModel.isLoading
    }

    var body: some View {
        ZStack {
            // Pake Material biar ada efek glass/vibrant khas macOS
            VisualEffectView(material: .underWindowBackground, blendingMode: .behindWindow)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                headerSection
                
                // Form Section
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 12) {
                        CustomInputField(title: "Username / Email", text: $email, hint: "nunu / nunu@mail.com")
                        CustomInputField(title: "Password", text: $password, hint: "••••••••", isSecure: true)
                    }
                    .frame(width: componentWidth)
                    
                    errorSection
                }
                
                // Action Section
                VStack(spacing: 15) {
                    loginButton
                    signUpButton
                }
            }
            .padding(40)
        }
        .frame(width: 400, height: 480)
    }
}

// MARK: - Subviews
private extension LoginView {
    
    var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "lock.applewatch") // Lebih estetik dibanding shield biasa
                .font(.system(size: 55))
                .foregroundStyle(.linearGradient(colors: [.blue, .cyan], startPoint: .top, endPoint: .bottom))
            
            Text("OmniAdmin")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            Text("Secure Access Gateway")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    @ViewBuilder
    var errorSection: some View {
        if viewModel.isError {
            Text(viewModel.errorMessage)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.red)
                .multilineTextAlignment(.center)
                .frame(width: componentWidth)
                .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
    
    var loginButton: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .controlSize(.small)
                    .frame(width: componentWidth, height: 32)
            } else {
                Button(action: {
                    Task {
                        await viewModel.login(username: email, password: password)
                        if let user = viewModel.loggedInUser {
                            authManager.loginSuccess(user: user)
                        }
                    }
                }) {
                    // Pake frame di Text biar area klik-nya pas 260px
                    Text("Sign In")
                        .fontWeight(.semibold)
                        .frame(width: componentWidth, height: 20)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(canSubmit ? .blue : .secondary)
                .disabled(!canSubmit)
                .keyboardShortcut(.defaultAction)
            }
        }
    }
    
    var signUpButton: some View {
        Button(action: onSignUpTapped) {
            Text("Create New Account")
                .font(.subheadline)
                .frame(width: componentWidth)
        }
        .buttonStyle(.plain)
        .foregroundStyle(.blue)
    }
}

// Helper buat background transparan ala macOS
struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}

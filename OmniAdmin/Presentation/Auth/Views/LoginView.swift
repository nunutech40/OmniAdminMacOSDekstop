//
//  LoginView.swift
//  OmniAdmin
//
//  Created by Nunu Nugraha on 25/12/25.
//

import SwiftUI

struct LoginView: View {
    // VM pake gaya @Observable (macOS 15)
    var viewModel: LoginViewModel
    
    // 1. Tambahin ini buat akses state global
    @EnvironmentObject var authManager: AuthenticationManager
    
    var onSignUpTapped: () -> Void
    
    @State private var email = ""
    @State private var password = ""
    
    var canSubmit: Bool {
        (email.isValidEmail || email.isValidUsername) &&
        password.isValidPassword &&
        !viewModel.isLoading
    }

    var body: some View {
        ZStack {
            Color(NSColor.windowBackgroundColor).ignoresSafeArea()
            
            VStack(spacing: 20) {
                // ... Header Image & Text ...
                headerSection
                
                VStack(alignment: .leading, spacing: 12) {
                    CustomInputField(title: "Username / Email", text: $email, hint: "nunu / nunu@mail.com")
                    CustomInputField(title: "Password", text: $password, hint: "••••••••", isSecure: true)
                }
                .frame(width: 250)
                
                if viewModel.isError {
                    Text(viewModel.errorMessage).font(.caption).foregroundStyle(.red)
                }
                
                if viewModel.isLoading {
                    ProgressView().controlSize(.small)
                } else {
                    Button(action: {
                        Task {
                            // 2. Eksekusi Login
                            await viewModel.login(username: email, password: password)
                            
                            // 3. JIKA SUKSES: Langsung update authManager di sini!
                            if let user = viewModel.loggedInUser {
                                authManager.loginSuccess(user: user)
                            }
                        }
                    }) {
                        Text("Login").frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(canSubmit ? .blue : .gray)
                    .disabled(!canSubmit)
                    .keyboardShortcut(.defaultAction)
                }
                
                Button("Sign Up") { onSignUpTapped() }
                    .buttonStyle(.plain)
                    .foregroundStyle(.blue)
            }
        }
        .frame(width: 400, height: 450)
    }
}

// Header helper biar rapi
private extension LoginView {
    var headerSection: some View {
        VStack(spacing: 10) {
            Image(systemName: "lock.shield.fill").font(.system(size: 50)).foregroundStyle(.blue)
            Text("OmniAdmin Login").font(.title).fontWeight(.bold)
        }
    }
}

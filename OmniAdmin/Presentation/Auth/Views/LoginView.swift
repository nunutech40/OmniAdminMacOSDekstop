//
//  LoginView.swift
//  OmniAdmin
//
//  Created by Nunu Nugraha on 25/12/25.
//

import SwiftUI
import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: LoginViewModel
    
    @State private var email = ""
    @State private var password = ""
    
    // MARK: - Validation Logic
    // Menggunakan extension String yang lo buat
    var isInputValid: Bool {
        // Karena label lo "Username / Email", kita cek salah satu harus valid
        email.isValidEmail || email.isValidUsername
    }
    
    var isPasswordValid: Bool {
        password.isValidPassword
    }
    
    var canSubmit: Bool {
        isInputValid && isPasswordValid && !viewModel.isLoading
    }
    
    var body: some View {
        ZStack {
            Color(NSColor.windowBackgroundColor).ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(.blue)
                
                Text("OmniAdmin Login")
                    .font(.title)
                    .fontWeight(.bold)
                
                VStack(alignment: .leading, spacing: 12) {
                    // FIELD: USERNAME / EMAIL
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Username / Email")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        TextField("nunu / nunu@mail.com", text: $email)
                            .textFieldStyle(.roundedBorder)
                            .disabled(viewModel.isLoading)
                        
                        // Hint Error Email/Username
                        if !email.isEmpty && !isInputValid {
                            Text("Format email atau username (min. 4 karakter) tidak valid")
                                .font(.system(size: 10))
                                .foregroundStyle(.red)
                        }
                    }
                    
                    // FIELD: PASSWORD
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Password")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        SecureField("••••••••", text: $password)
                            .textFieldStyle(.roundedBorder)
                            .disabled(viewModel.isLoading)
                        
                        // Hint Error Password
                        if !password.isEmpty && !isPasswordValid {
                            Text("Password minimal 8 karakter")
                                .font(.system(size: 10))
                                .foregroundStyle(.red)
                        }
                    }
                }
                .frame(width: 250)
                
                // ERROR DARI SERVER
                if viewModel.isError {
                    Text(viewModel.errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .frame(width: 250)
                }
                
                // BUTTON SECTION
                if viewModel.isLoading {
                    ProgressView().controlSize(.small)
                } else {
                    Button(action: {
                        Task { await viewModel.login(username: email, password: password) }
                    }) {
                        Text("Login").frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    // Tint berubah jadi abu-abu kalau belum valid biar user tau dia gak bisa klik
                    .tint(canSubmit ? .blue : .gray)
                    .keyboardShortcut(.defaultAction)
                    .frame(width: 250)
                    .disabled(!canSubmit) // SEKARANG PAKE LOGIC VALIDASI
                }
            }
        }
        .frame(width: 400, height: 450)
        // Animasi biar pesan error munculnya gak kaget
        .animation(.easeIn(duration: 0.2), value: email)
        .animation(.easeIn(duration: 0.2), value: password)
    }
}

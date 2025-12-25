//
//  LoginView.swift
//  OmniAdmin
//
//  Created by Nunu Nugraha on 25/12/25.
//
import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 50))
                .foregroundStyle(.blue)
            
            Text("OmniAdmin Login")
                .font(.title)
                .fontWeight(.bold)
            
            VStack(alignment: .leading) {
                Text("Email")
                    .font(.caption)
                TextField("nunu@example.com", text: $email)
                    .textFieldStyle(.roundedBorder)
                
                Text("Password")
                    .font(.caption)
                    .padding(.top, 8)
                SecureField("••••••••", text: $password)
                    .textFieldStyle(.roundedBorder)
            }
            .frame(width: 250)
            
            if isLoading {
                ProgressView()
                    .controlSize(.small)
            } else {
                Button(action: handleLogin) {
                    Text("Login")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction) // Enter buat login
                .frame(width: 250)
                .disabled(email.isEmpty || password.isEmpty)
            }
        }
        .padding(40)
        // Ukuran window login macOS yang pas
        .frame(width: 400, height: 450)
    }

    func handleLogin() {
        isLoading = true
        // Simulasi hit API JWT
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            authManager.login(jwt: "dummy-jwt-token")
            isLoading = false
        }
    }
}

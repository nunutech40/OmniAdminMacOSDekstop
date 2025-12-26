//
//  LoginView.swift
//  OmniAdmin
//
//  Created by Nunu Nugraha on 25/12/25.
//

import SwiftUI

struct LoginView: View {
    // Inject VM dari ContentView (Manual DI)
    @ObservedObject var viewModel: LoginViewModel
    
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 50))
                .foregroundStyle(.blue)
            
            Text("OmniAdmin Login")
                .font(.title)
                .fontWeight(.bold)
            
            VStack(alignment: .leading) {
                Text("Username / Email")
                    .font(.caption)
                TextField("nunu", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .disabled(viewModel.isLoading)
                
                Text("Password")
                    .font(.caption)
                    .padding(.top, 8)
                SecureField("••••••••", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .disabled(viewModel.isLoading)
            }
            .frame(width: 250)
            
            // Tampilkan error kalau login gagal
            if viewModel.isError {
                Text(viewModel.errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .frame(width: 250)
            }
            
            if viewModel.isLoading {
                ProgressView()
                    .controlSize(.small)
            } else {
                Button(action: {
                    Task {
                        await viewModel.login(username: email, password: password)
                    }
                }) {
                    Text("Login")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
                .frame(width: 250)
                .disabled(email.isEmpty || password.isEmpty)
            }
        }
        .padding(40)
        .frame(width: 400, height: 450)
    }
}

//
//  ContentView.swift
//  OmniAdmin
//
//  Created by Nunu Nugraha on 25/12/25.
//

import SwiftUI
struct ContentView: View {
    @EnvironmentObject var authManager: AuthenticationManager

    var body: some View {
        // Gunakan Group agar transisi lebih clean
        Group {
            if authManager.isCheckingAuth {
                splashView
            } else if authManager.isAuthenticated {
                createDashboardModule()
            } else {
                createLoginModule()
            }
        }
        // Taruh frame di level root biar window gak "kaget"
        .frame(minWidth: authManager.isAuthenticated ? 1000 : 400,
                       minHeight: authManager.isAuthenticated ? 700 : 450)
        .animation(.easeInOut(duration: 0.3), value: authManager.isAuthenticated)
        .animation(.easeInOut(duration: 0.3), value: authManager.isCheckingAuth)
    }
}

// MARK: - View Helpers (Module Factory)
private extension ContentView {
    
    // View Splash Simpel
    var splashView: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 60))
                .foregroundStyle(.blue)
            
            ProgressView()
                .controlSize(.small)
        }
        .frame(width: 400, height: 450) // Samain sama size LoginView
    }

    // Builder untuk Login Module
    func createLoginModule() -> some View {
        let repository = Injection.shared.provideUserRepository()
        let viewModel = LoginViewModel(repository: repository)
        
        return LoginView(viewModel: viewModel)
            .onReceive(viewModel.$loggedInUser) { user in
                if let user = user {
                    // Update state global via AuthManager
                    authManager.loginSuccess(user: user)
                }
            }
    }

    // Builder untuk Dashboard Module
    func createDashboardModule() -> some View {
        // Karena Dashboard lo butuh Repo Portfolio, nanti daftarin di Injection juga
        MainDashboard()
    }
}

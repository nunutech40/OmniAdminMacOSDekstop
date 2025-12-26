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
        ZStack {
            if authManager.isCheckingAuth {
                // 1. SPLASH SCREEN (Sedang ngecek token di Keychain)
                splashView
                    .transition(.opacity)
            } else if authManager.isAuthenticated {
                // 2. MAIN DASHBOARD (Sudah Login)
                createDashboardModule()
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.95)),
                        removal: .opacity
                    ))
            } else {
                // 3. LOGIN SCREEN (Belum Login)
                createLoginModule()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        // Animasi perpindahan antar state
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: authManager.isCheckingAuth)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: authManager.isAuthenticated)
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

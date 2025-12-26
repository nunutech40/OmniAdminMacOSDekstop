//
//  ContentView.swift
//  OmniAdmin
//
//  Created by Nunu Nugraha on 25/12/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var showRegister = false

    var body: some View {
        ZStack {
            Color(NSColor.windowBackgroundColor).ignoresSafeArea()

            if authManager.isCheckingAuth {
                splashView
            } else if authManager.isAuthenticated {
                // Dashboard otomatis muncul pas isAuthenticated jadi true
                createDashboardModule()
            } else {
                if showRegister {
                    createRegisterModule()
                } else {
                    createLoginModule()
                }
            }
        }
        .frame(
            minWidth: authManager.isAuthenticated ? 1000 : 400,
            maxWidth: authManager.isAuthenticated ? .infinity : 400,
            minHeight: authManager.isAuthenticated ? 650 : 450,
            maxHeight: authManager.isAuthenticated ? .infinity : 450
        )
        .animation(.easeInOut(duration: 0.3), value: authManager.isAuthenticated)
    }
}

// MARK: - Factory Helpers
private extension ContentView {
    
    func createLoginModule() -> some View {
        let repository = Injection.shared.provideUserRepository()
        let viewModel = LoginViewModel(repository: repository)
        
        // Cukup return view-nya aja, logic pindah layar udah di dalem LoginView
        return LoginView(viewModel: viewModel, onSignUpTapped: {
            showRegister = true
        })
    }

    func createRegisterModule() -> some View {
        let repo = Injection.shared.provideUserRepository()
        let viewModel = RegisterViewModel(repository: repo)
        return RegisterView(viewModel: viewModel, onBackToLoginTapped: {
            showRegister = false
        })
    }
    
    func createDashboardModule() -> some View {
        MainDashboard()
    }

    var splashView: some View {
        VStack {
            ProgressView()
        }.frame(width: 400, height: 450)
    }
}

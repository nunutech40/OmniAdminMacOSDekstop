//
//  ContentView.swift
//  OmniAdmin
//
//  Created by Nunu Nugraha on 25/12/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var authManager = AuthManager()

    var body: some View {
        ZStack {
            if authManager.isAuthenticated {
                MainDashboard()
                    .environmentObject(authManager)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.95)),
                        removal: .opacity
                    ))
            } else {
                LoginView()
                    .environmentObject(authManager)
                    .transition(.opacity)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: authManager.isAuthenticated)
    }
}

// Preview buat ngetes tanpa run full app
#Preview {
    ContentView()
}

#Preview {
    ContentView()
}

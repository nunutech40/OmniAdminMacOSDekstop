//
//  OmniAdminApp.swift
//  OmniAdmin
//
//  Created by Nunu Nugraha on 25/12/25.
//

import SwiftUI

@main
struct OmniAdminApp: App {
    @StateObject private var authManager = Injection.shared.provideAuthManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
        }
        .windowResizability(.contentSize)
    }
}

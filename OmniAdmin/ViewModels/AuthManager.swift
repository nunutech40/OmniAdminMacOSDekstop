//
//  AuthManager.swift
//  OmniAdmin
//
//  Created by Nunu Nugraha on 25/12/25.
//

import SwiftUI

class AuthManager: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var token: String? = nil
    
    // Fungsi simulasi login
    func login(jwt: String) {
        withAnimation {
            self.token = jwt
            self.isAuthenticated = true
        }
    }
    
    // Fungsi logout buat ngetes balik ke LoginView
    func logout() {
        withAnimation {
            self.token = nil
            self.isAuthenticated = false
        }
    }
}

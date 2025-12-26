//
//  UserInfo.swift
//  OmniAdmin
//
//  Created by Nunu Nugraha on 26/12/25.
//

import Foundation

struct UserInfo: Codable, Identifiable, Hashable {
    let id: UUID
    let username: String
    let role: String
}

// Model ini yang masuk ke AppResponse<LoginResponse>
struct LoginResponse: Codable {
    let token: String
    let user: UserInfo
}

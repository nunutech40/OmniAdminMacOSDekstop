//
//  APIConstants.swift
//  OmniAdmin
//
//  Created by Nunu Nugraha on 25/12/25.
//

import Foundation

struct APIConstants {
    // Ganti ke IP Server lo jika ngetes dari real device
    static let baseURL = "http://157.10.161.215:8080"
    
    struct Endpoints {
        // Users / Auth
        static let login = "/users/login"
        static let register = "/users/register"
        static let me = "/users/me"
        
        // Portfolios
        static let portfolios = "/portfolios"
        
        // Tech Stacks
        static let techs = "/techs"
    }
}

//
//  APIError.swift
//  OmniAdmin
//
//  Created by Nunu Nugraha on 25/12/25.
//

import Foundation

enum APIError: Error, LocalizedError {
    case networkError(String)     // Gak ada internet / server down
    case serverError(String)      // success: false dari Vapor lo
    case decodingError            // JSON-nya berantakan
    case unauthorized             // Token expired / 401
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .networkError(let msg): return "Network Error: \(msg)"
        case .serverError(let msg): return msg
        case .decodingError: return "Gagal memproses data dari server."
        case .unauthorized: return "Sesi berakhir, silakan login ulang."
        case .unknown: return "Terjadi kesalahan yang tidak diketahui."
        }
    }
}

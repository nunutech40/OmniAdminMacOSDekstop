//
//  APIConstants.swift
//  OmniAdmin
//
//  Created by Nunu Nugraha on 25/12/25.
//

import Foundation

/// `APIConstants` mengelola konfigurasi dasar koneksi API.
/// Menggunakan Conditional Compilation untuk memisahkan jalur data antara tahap pengembangan dan produksi.
struct APIConstants {
    
    /// Alamat utama server yang dipilih secara otomatis berdasarkan Build Configuration.
    ///
    /// - **Debug Mode (Run):** Menggunakan Port 8081 yang terhubung ke database `omni_db_dev`.
    /// - **Release Mode (Archive):** Menggunakan Port 8080 yang terhubung ke database production `omni_db`.
    static var baseURL: String {
    #if DEBUG
        // Jalur ini aktif ketika aplikasi dijalankan melalui Xcode (Cmd + R)
        // Memastikan aktivitas testing tidak mengotori data asli di production.
        return "http://157.10.161.215:8081"
    #else
        // Jalur ini aktif ketika aplikasi di-Archive atau di-distribusikan ke user.
        // Mengarah ke server stabil dengan database utama.
        return "http://157.10.161.215:8080"
    #endif
    }
    
    /// Daftar lengkap endpoint API yang tersedia di server OmniAdmin.
    struct Endpoints {
        // MARK: - Users / Auth
        // Cek lagi di routes.swift, kalau UserController GAK pake grup "api", ini tetep begini.
        static let login = "/users/login"
        static let register = "/users/register"
        static let me = "/users/me"
        
        // MARK: - Portfolios
        // TAMBAHKAN /api di depan sini
        static let portfolios = "/portfolios"
        
        // MARK: - Tech Stacks
        static let techs = "/techs" // Biasanya TechStack jg masuk grup api
    }
}

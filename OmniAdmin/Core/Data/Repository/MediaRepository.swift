//
//  MediaRepository.swift
//  OmniAdmin
//
//  Created by Nunu Nugraha on 29/12/25.
//
import Foundation

// MARK: - MediaRepository.swift
protocol MediaRepositoryProtocol {
    func uploadImage(data: Data, fileName: String, mimeType: String) async throws -> String
}

final class MediaRepository: MediaRepositoryProtocol {
    private let client: APIClient
    init(client: APIClient) { self.client = client }

    func uploadImage(data: Data, fileName: String, mimeType: String) async throws -> String {
        // Panggil fungsi upload yang kita buat di APIClient sebelumnya
        return try await client.upload("/media/upload", fileData: data, fileName: fileName, mimeType: mimeType)
    }
}

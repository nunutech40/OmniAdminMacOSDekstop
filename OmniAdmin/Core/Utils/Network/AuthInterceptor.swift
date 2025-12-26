//
//  AuthInterceptor.swift
//  OmniAdmin
//
//  Created by Nunu Nugraha on 26/12/25.
//

import Foundation
import Alamofire

// 1. Tambahkan 'final'
// 2. Tambahkan '@unchecked Sendable' jika compiler masih komplain soal protocol
final class AuthInterceptor: RequestInterceptor, @unchecked Sendable {
    
    // Pastikan ini 'let' (immutable)
    private let secureStorage: SecureStorageProtocol
    
    init(secureStorage: SecureStorageProtocol) {
        self.secureStorage = secureStorage
    }
    
    // ADAPT & RETRY tetap sama kodenya...
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest
        if let token = secureStorage.getToken(key: "accessToken") {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        completion(.success(urlRequest))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        guard let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 else {
            return completion(.doNotRetry)
        }
        completion(.doNotRetry)
    }
}

//
//  APIClient.swift
//  OmniAdmin
//
//  Created by Nunu Nugraha on 25/12/25.
//

import Foundation
import Alamofire

class APIClient {
    // Singleton atau nanti di-inject via DI lo
    static let shared = APIClient()
    
    private init() {}
    
    /// Fungsi Utama untuk Request ke API
    /// - Parameters:
    ///   - endpoint: Path endpoint (ex: /portfolios)
    ///   - method: HTTP Method (.get, .post, .put, .delete)
    ///   - parameters: Body request (untuk POST/PUT)
    ///   - token: JWT Token (Opsional, dari AuthManager)
    func request<T: Decodable>(
        _ endpoint: String,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        token: String? = nil
    ) async throws -> T { // Kita balikin T langsung, karena wrapper sudah dicheck di sini
        
        let url = APIConstants.baseURL + endpoint
        var headers: HTTPHeaders = ["Accept": "application/json"]
        if let token = token { headers.add(.authorization(bearerToken: token)) }
        
        let dataTask = AF.request(url, method: method, parameters: parameters,
                                  encoding: JSONEncoding.default, headers: headers)
            .serializingDecodable(AppResponse<T>.self)
        
        let response = await dataTask.response
        
        switch response.result {
        case .success(let appResponse):
            // 1. Check flag success dari Vapor lo
            if appResponse.success {
                guard let data = appResponse.data else {
                    // Kasus sukses tapi data null (misal Delete sukses)
                    throw APIError.unknown
                }
                return data
            } else {
                // 2. Mapping error dari server
                if response.response?.statusCode == 401 {
                    throw APIError.unauthorized
                }
                throw APIError.serverError(appResponse.message)
            }
            
        case .failure(let error):
            // 3. Mapping error network/parsing
            if error.isResponseSerializationError {
                throw APIError.decodingError
            }
            throw APIError.networkError(error.localizedDescription)
        }
    }
}

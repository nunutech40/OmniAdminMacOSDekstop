//
//  APIClient.swift
//  OmniAdmin
//
//  Created by Nunu Nugraha on 25/12/25.
//

import Foundation
import Alamofire

class APIClient {
    static let shared = APIClient()
    
    private let session: Session
    private let secureStorage: SecureStorageProtocol
    
    private init(secureStorage: SecureStorageProtocol = SecureStorage()) {
        self.secureStorage = secureStorage
        
        // DAFTARKAN INTERCEPTOR KE SESSION
        let interceptor = AuthInterceptor(secureStorage: secureStorage)
        self.session = Session(interceptor: interceptor)
    }
    
    func request<T: Decodable>(
        _ endpoint: String,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil
    ) async throws -> T {
        
        let url = APIConstants.baseURL + endpoint
        
        // GANTI AF.request JADI session.request
        // Header Authorization sekarang diurus otomatis oleh Interceptor!
        let dataTask = session.request(
            url,
            method: method,
            parameters: parameters,
            encoding: JSONEncoding.default
        )
        .serializingDecodable(AppResponse<T>.self)
        
        let response = await dataTask.response
        
        // Logic switch response lo tetep sama...
        switch response.result {
        case .success(let appResponse):
            if appResponse.success {
                guard let data = appResponse.data else { throw APIError.unknown }
                return data
            } else {
                throw APIError.serverError(appResponse.message)
            }
        case .failure(let error):
            throw APIError.networkError(error.localizedDescription)
        }
    }
}

//
//  APIModel.swift
//  OmniAdmin
//
//  Created by Nunu Nugraha on 25/12/25.
//

import Foundation

struct AppResponse<T: Decodable>: Decodable {
    let success: Bool
    let message: String
    let data: T?
    let error: String?
}

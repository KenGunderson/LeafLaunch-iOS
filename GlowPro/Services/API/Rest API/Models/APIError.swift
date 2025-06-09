//
//  APIError.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 4/19/24.
//

import Foundation

enum APIError: Error, AppCustomError {    
    
    case badURL
    case serverError(statusCode: Int, errorMessage: String)
    case decodingError
    case unknownError
    
    var message: String {
        switch self {
        case .badURL: return "Invalid url"
        case .serverError(_, let errorMessage): return errorMessage
        case .decodingError: return "There was an error decoding the response."
        case .unknownError: return "An unknown error occurred."
        }
    }
    
}

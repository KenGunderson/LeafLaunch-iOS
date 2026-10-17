//
//  APIError.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 4/19/24.
//

import Foundation

enum APIError: Error, AppCustomError {

    enum PlatformError: Decodable {

        case test(name: String, test: String)
        case unknown(code: String, message: String?)

        private enum CodingKeys: String, CodingKey {

            case code
            case name
            case type
            case message

        }

        init(from decoder: Decoder) throws {

            let container = try decoder.container(keyedBy: CodingKeys.self)
            let type = try container.decode(String.self, forKey: .type)

            switch type {
            case "test":

                self = .test(
                    name: try container.decode(String.self, forKey: .name),
                    test: try container.decode(String.self, forKey: .type)
                )

            default:

                self = .unknown(
                    code: "unkown",
                    message: try container.decodeIfPresent(String.self, forKey: .message)
                )
            }

        }

    }

    case badURL
    case missingAccessToken
    case serverError(statusCode: Int, errorMessage: String)
    case decodingError
    case unknownError
    case platformError(PlatformError)

    var message: String {

        switch self {
        case .badURL: return "Invalid URL"
        case .missingAccessToken: return "Missing access token"
        case .serverError(_, let errorMessage): return errorMessage
        case .decodingError: return "There was an error decoding the response."
        case .unknownError: return "An unknown error occurred."
        case .platformError(let error):

            switch error {
            case .test(let name, let test): return "\(name) \(test)"
            case .unknown(_, let message): return message ?? "An unknown platform error occurred."
            }

        }

    }

}

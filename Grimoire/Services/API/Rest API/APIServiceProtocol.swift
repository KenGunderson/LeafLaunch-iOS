//
//  APIServiceProtocol.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 7/13/24.
//

import Foundation

enum RequestBody {
    
    case none
    case json([String: Any])
    case multipart(boundary: String, data: Data)
    
}

protocol APIProtocol: AnyObject, Sendable, Loggable {
    
    var environment: AppEnvironment? { get }
    var hostURL: String { get }
    var accessToken: String? { get set }
    
}

protocol APIServiceProtocol: APIProtocol {
    
    var accessToken: String? { get set }
    var deviceToken: String? { get }
    var environment: AppEnvironment? { get }
    var hostURL: String { get }
    
    // Health
    
    func getHealth() async throws
    
    // Device
    
    func registerDevice(token: String, userId: String) async throws
    
    // Users
    
    func getUser(id: String) async throws -> GPUser
    func getUserProfile() async throws -> GPUser
    func getFirebaseTokenForUser(email: String) async throws -> String
    func updateUser(user: GPUser) async throws
    func createUser(user: GPUser) async throws -> GPUser
    func deleteUser(user: GPUser) async throws
    
}

extension APIProtocol {
    
    func buildRequest(method: HTTPRequestMethod,
                      apiPath: APIPath,
                      queryParameters: [String: String] = [:],
                      parameters: [String: Any] = [:]) async throws -> Data {
        
        var apiLogResponse: APILogResponse?
        
        defer {
            
            if let apiLogResponse {
                APILogResponseStore.shared.append(apiLogResponse)
            }
            
        }
        
        let request = try makeRequest(
            method: method,
            apiPath: apiPath,
            queryParameters: queryParameters,
            body: .json(parameters)
        )
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        apiLogResponse = APILogResponse(
            method: method.rawValue,
            path: request.url?.absoluteString ?? "No URL Provided",
            statusCode: (response as? HTTPURLResponse)?.statusCode ?? -1,
            headers: request.allHTTPHeaderFields ?? [:],
            queryParameters: queryParameters,
            body: parameters,
            responseData: data
        )
        
        if let error = handleErrorResponse(data: data, response: response) {
            
            apiLogResponse?.error = error
            throw error
            
        }
        
        return data
        
    }
    
    func buildMultipartRequest(method: HTTPRequestMethod,
                               apiPath: APIPath,
                               boundary: String,
                               data: Data) async throws -> Data {
        
        var apiLogResponse: APILogResponse?
        
        defer {
            
            if let apiLogResponse {
                APILogResponseStore.shared.append(apiLogResponse)
            }
            
        }
        
        let request = try makeRequest(
            method: method,
            apiPath: apiPath,
            queryParameters: [:],
            body: .multipart(boundary: boundary, data: data)
        )
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        apiLogResponse = APILogResponse(
            method: method.rawValue,
            path: request.url?.absoluteString ?? "No URL Provided",
            statusCode: (response as? HTTPURLResponse)?.statusCode ?? -1,
            headers: request.allHTTPHeaderFields ?? [:],
            queryParameters: [:],
            body: [:],
            responseData: data
        )
        
        if let error = handleErrorResponse(data: data, response: response) {
            
            apiLogResponse?.error = error
            throw error
            
        }
        
        return data
        
    }
    
}

extension APIProtocol {
    
    func parseData<T: Decodable>(data: Data) throws -> T {
        
        do {
            
            return try JSONDecoder().decode(T.self, from: data)
            
        } catch let error as DecodingError {
            
            let detailedMessage: String
            
            switch error {
            case .keyNotFound(let key, let context):
                detailedMessage = """
                Decoding Error: Key Not Found
                Missing key: \(key.stringValue)
                Coding path: \(context.codingPath.map(\.stringValue).joined(separator: " -> "))
                Debug description: \(context.debugDescription)
                """
                
            case .typeMismatch(let type, let context):
                detailedMessage = """
                Decoding Error: Type Mismatch
                Mismatched type: \(type)
                Coding path: \(context.codingPath.map(\.stringValue).joined(separator: " -> "))
                Debug description: \(context.debugDescription)
                """
                
            case .valueNotFound(let value, let context):
                detailedMessage = """
                Decoding Error: Value Not Found
                Missing value: \(value)
                Coding path: \(context.codingPath.map(\.stringValue).joined(separator: " -> "))
                Debug description: \(context.debugDescription)
                """
                
            case .dataCorrupted(let context):
                detailedMessage = """
                Decoding Error: Data Corrupted
                Coding path: \(context.codingPath.map(\.stringValue).joined(separator: " -> "))
                Debug description: \(context.debugDescription)
                """
                
            @unknown default:
                detailedMessage = "Unknown decoding error occurred."
            }
            
            self.logError(title: detailedMessage, message: "Decoding Error")
            
        } catch {
            
            self.logError(
                title: "Decoding Error",
                message: "Unknown error: \(error.getMessageForError())"
            )
            
        }
        
        throw NSError(
            domain: "NetworkAPIError",
            code: 3,
            userInfo: [NSLocalizedDescriptionKey: "JSON decode error"]
        )
        
    }
    
    private func handleErrorResponse(data: Data,
                                     response: URLResponse) -> APIError? {
        
        let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        let zodErrorMessage = zodErrorDescription(errorJson)
        
        let errorMessage = errorJson?["error"] as? String
        
        let errorDescription = errorJson?["message"] as? String
        
        if let httpResponse = response as? HTTPURLResponse {
            let statusCode = httpResponse.statusCode
            
            let badStatusCodes = 400...599
            
            if badStatusCodes.contains(statusCode) {
                
                let message = zodErrorMessage ?? errorDescription ?? errorMessage
                
                self.logError(
                        title: "API Service Error",
                        message: message ?? "We don't know what went wrong, but it did!"
                    )
                
                return APIError.serverError(
                    statusCode: statusCode,
                    errorMessage: message ?? "We don't know what went wrong, but it did!"
                )
                
            }
            
        }
        
        return nil
        
    }
    
    private func zodErrorDescription(_ errorDict: [String : Any]?) -> String? {
        
        guard let errorDict,
              let error = errorDict["error"] as? [String : Any],
              let issues = error["issues"] as? [Any],
              let first = issues.first as? [String: Any]
        else {
            return nil
        }
        
        let code = first["code"] as? String ?? "unknown_code"
        let path = (first["path"] as? [String])?.joined(separator: ".") ?? "unknown_field"
        let message = first["message"] as? String ?? "Invalid value"
        let expected = first["expected"] as? String ?? "unknown"
        let received = first["received"] as? String ?? "unknown"
        
        return "Field '\(path)': \(message) (expected \(expected), received \(received)) [\(code)]"
    }
    
}

extension APIProtocol {
    
    func makeRequest(method: HTTPRequestMethod,
                     apiPath: APIPath,
                     queryParameters: [String: String],
                     body: RequestBody) throws -> URLRequest {
        
        guard var urlComponents = URLComponents(string: "\(self.hostURL)/\(apiPath.path.buildURL)") else {
            throw URLError(.badURL)
        }
        
        if !queryParameters.isEmpty {
            urlComponents.queryItems = queryParameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        guard let url = urlComponents.url else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue(Self.appVersion, forHTTPHeaderField: "App-Version")
        
        if let accessToken = self.accessToken,
           !accessToken.isEmpty {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        switch body {
        case .none:
            break
            
        case .json(let parameters):
            
            if !parameters.isEmpty {
                
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
            }
            
        case .multipart(let boundary, let data):
            
            request.httpBody = data
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
        }
        
        log(message: buildRequestLog(
            method: method,
            url: request.url,
            queryParameters: queryParameters,
            body: body
        ))
        
        return request
        
    }
    
    func buildRequestLog(method: HTTPRequestMethod,
                         url: URL?,
                         queryParameters: [String: String],
                         body: RequestBody) -> String {
        
        var customLog: String = """
        METHOD: \(method.rawValue.uppercased())
        OUTGOING URL: \(url?.absoluteString ?? "No URL Provided")
        """
        
        if !queryParameters.isEmpty {
            customLog.append("\nQUERY PARAMS: \(queryParameters)")
        }
        
        if let params = body.jsonParameters,
           !params.isEmpty {
            customLog.append("\nPARAMETERS: \(params)")
        }
        
        return customLog
        
    }
    
    static var appVersion: String {
        "1.0.0"
    }
    
}

private extension RequestBody {
    
    var jsonParameters: [String: Any]? {
        
        switch self {
        case .json(let params): return params
        default: return nil
        }
        
    }
    
}

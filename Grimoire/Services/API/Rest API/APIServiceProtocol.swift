//
//  APIServiceProtocol.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 7/13/24.
//

import Foundation

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
    
    func buildRequest(
        method: HTTPRequestMethod,
        apiPath: APIPath,
        queryParameters: [String: String]? = [:],
        parameters: [String: Any] = [:]) async throws -> Data {
            
            var apiLogResponse: APILogResponse?
            
            defer {
                
                if let apiLogResponse {
                    APILogResponseStore.shared.append(apiLogResponse)
                }
                
            }
            
            guard var urlComponents = URLComponents(string: "\(self.hostURL)/\(apiPath.path.buildURL)") else {
                throw URLError(.badURL)
            }
            
            if !(queryParameters?.isEmpty ?? false) {
                urlComponents.queryItems = queryParameters?.map { URLQueryItem(name: $0.key, value: $0.value) }
            }
            
            guard let url = urlComponents.url else {
                throw URLError(.badURL)
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = method.rawValue
            request.setValue("0.0.1", forHTTPHeaderField: "App-Version")
            request.setValue("Bearer \(self.accessToken ?? "")", forHTTPHeaderField: "Authorization")
            
            if !parameters.isEmpty {
                
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            }
            
            var customLog: String = """
            METHOD: \(method.rawValue.uppercased())
            OUTGOING URL: \(request.url?.absoluteString ?? "No URL Provided")
            """
            
            if let queryParameters,
               !queryParameters.isEmpty {
                
                customLog.append("\nQUERY PARAMS: \(queryParameters)")
                
            }
            
            if !parameters.isEmpty {
                customLog.append("\nPARAMETERS: \(parameters)")
            }
            
            self.log(message: customLog)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            apiLogResponse = APILogResponse(
                method: method.rawValue,
                path: request.url?.absoluteString ?? "No URL Provided",
                statusCode: (response as? HTTPURLResponse)?.statusCode ?? -1,
                headers: request.allHTTPHeaderFields ?? [:],
                queryParameters: queryParameters ?? [:],
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
        
        guard let urlComponents = URLComponents(string: "\(self.hostURL)/\(apiPath.path.buildURL)") else {
            throw URLError(.badURL)
        }
        
        guard let url = urlComponents.url else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = data
        
        request.setValue("1.0.0", forHTTPHeaderField: "App-Version")
        request.setValue("Bearer \(self.accessToken ?? "")", forHTTPHeaderField: "Authorization")
                
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let customLog: String = """
            METHOD: \(method.rawValue.uppercased())
            OUTGOING URL: \(request.url?.absoluteString ?? "No URL Provided")
            """
        
        self.log(message: customLog)
        
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

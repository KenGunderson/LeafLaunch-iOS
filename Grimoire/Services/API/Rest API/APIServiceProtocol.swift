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
    var networkSession: URLSession { get }
    var requestTimeout: TimeInterval { get }
    var resourceTimeout: TimeInterval { get }
    var maxRetryCount: Int { get }
    var retryBackoffNanoseconds: UInt64 { get }
    
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
        
        let includeSensitiveLogData = shouldIncludeSensitiveAPILogData()
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
        
        let (data, response, attemptCount) = try await performRequestWithRetry(
            request: request,
            method: method,
            path: apiPath.path.buildURL
        )
        
        apiLogResponse = APILogResponse(
            method: method.rawValue,
            path: request.url?.absoluteString ?? "No URL Provided",
            statusCode: (response as? HTTPURLResponse)?.statusCode ?? -1,
            headers: redactedHeaders(
                request.allHTTPHeaderFields ?? [:],
                includeSensitiveData: includeSensitiveLogData
            ),
            queryParameters: redactedQueryParameters(
                queryParameters,
                includeSensitiveData: includeSensitiveLogData
            ),
            body: redactedBody(parameters, includeSensitiveData: includeSensitiveLogData),
            responseData: data,
            attemptCount: attemptCount
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
        
        let includeSensitiveLogData = shouldIncludeSensitiveAPILogData()
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
        
        let (data, response, attemptCount) = try await performRequestWithRetry(
            request: request,
            method: method,
            path: apiPath.path.buildURL
        )
        
        apiLogResponse = APILogResponse(
            method: method.rawValue,
            path: request.url?.absoluteString ?? "No URL Provided",
            statusCode: (response as? HTTPURLResponse)?.statusCode ?? -1,
            headers: redactedHeaders(
                request.allHTTPHeaderFields ?? [:],
                includeSensitiveData: includeSensitiveLogData
            ),
            queryParameters: redactedQueryParameters(
                [:],
                includeSensitiveData: includeSensitiveLogData
            ),
            body: [:],
            responseData: data,
            attemptCount: attemptCount
        )
        
        if let error = handleErrorResponse(data: data, response: response) {
            
            apiLogResponse?.error = error
            throw error
            
        }
        
        return data
        
    }
    
}

extension APIProtocol {
    
    private func shouldIncludeSensitiveAPILogData() -> Bool {
        
        guard let environment = self.environment else { return false }
        
        switch environment {
        case .production:
            return false
        case .localhost, .development, .custom:
            return true
        }
        
    }
    
    private func redactedHeaders(_ headers: [String: String],
                                 includeSensitiveData: Bool) -> [String: String] {
        
        guard !includeSensitiveData else { return headers }
        
        let sensitiveHeaderKeys: Set<String> = [
            "authorization",
            "cookie",
            "set-cookie",
            "x-api-key",
            "api-key",
            "token"
        ]
        
        return headers.reduce(into: [String: String]()) { partialResult, item in
            
            if sensitiveHeaderKeys.contains(item.key.lowercased()) {
                partialResult[item.key] = "<redacted>"
            }
            else {
                partialResult[item.key] = item.value
            }
            
        }
        
    }
    
    private func redactedQueryParameters(_ queryParameters: [String: String],
                                         includeSensitiveData: Bool) -> [String: String] {
        
        guard !includeSensitiveData else { return queryParameters }
        
        return queryParameters.reduce(into: [String: String]()) { partialResult, item in
            partialResult[item.key] = "<redacted>"
        }
        
    }
    
    private func redactedBody(_ body: [String: Any],
                              includeSensitiveData: Bool) -> [String: Any] {
        
        guard !includeSensitiveData else { return body }
        guard !body.isEmpty else { return body }
        
        return [
            "_redacted": true,
            "_keys": body.keys.sorted()
        ]
        
    }
    
    private func performRequestWithRetry(request: URLRequest,
                                         method: HTTPRequestMethod,
                                         path: String) async throws -> (Data, URLResponse, Int) {
        
        var attempt = 0
        var currentBackoff = max(self.retryBackoffNanoseconds, 100_000_000)
        var latestResponse: (Data, URLResponse)?
        
        while attempt <= self.maxRetryCount {
            
            attempt += 1
            
            do {
                
                let response = try await self.networkSession.data(for: request)
                latestResponse = response
                
                if let httpResponse = response.1 as? HTTPURLResponse,
                   shouldRetry(statusCode: httpResponse.statusCode),
                   attempt <= self.maxRetryCount {
                    
                    self.log(
                        level: .info,
                        message: """
                        Retrying API request after status code \(httpResponse.statusCode)
                        Attempt: \(attempt)
                        Path: \(path)
                        """
                    )
                    
                    try await Task.sleep(nanoseconds: currentBackoff)
                    currentBackoff *= 2
                    continue
                    
                }
                
                return (response.0, response.1, attempt)
                
            }
            catch {
                
                guard shouldRetry(error: error),
                      attempt <= self.maxRetryCount else {
                    
                    self.logError(
                        title: "API Request Failed",
                        message: """
                        Method: \(method.rawValue.uppercased())
                        Attempt: \(attempt)
                        Path: \(path)
                        Error: \(error.getMessageForError())
                        """
                    )
                    
                    throw error
                    
                }
                
                self.log(
                    level: .info,
                    message: """
                    Retrying API request after transport error
                    Attempt: \(attempt)
                    Path: \(path)
                    Error: \(error.getMessageForError())
                    """
                )
                
                try await Task.sleep(nanoseconds: currentBackoff)
                currentBackoff *= 2
                
            }
            
        }
        
        if let latestResponse {
            return (latestResponse.0, latestResponse.1, attempt)
        }
        
        throw APIError.unknownError
        
    }
    
    private func shouldRetry(statusCode: Int) -> Bool {
        
        let retryableStatusCodes: Set<Int> = [408, 425, 429, 500, 502, 503, 504]
        return retryableStatusCodes.contains(statusCode)
        
    }
    
    private func shouldRetry(error: Error) -> Bool {
        
        guard let urlError = error as? URLError else { return false }
        
        let retryableCodes: Set<URLError.Code> = [
            .timedOut,
            .cannotFindHost,
            .cannotConnectToHost,
            .networkConnectionLost,
            .dnsLookupFailed,
            .notConnectedToInternet
        ]
        
        return retryableCodes.contains(urlError.code)
        
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
        request.timeoutInterval = self.requestTimeout
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
        
        let includeSensitiveData = shouldIncludeSensitiveAPILogData()
        
        var customLog: String = """
        METHOD: \(method.rawValue.uppercased())
        OUTGOING URL: \(url?.absoluteString ?? "No URL Provided")
        """
        
        if !queryParameters.isEmpty {
            
            if includeSensitiveData {
                customLog.append("\nQUERY PARAMS: \(queryParameters)")
            }
            else {
                customLog.append("\nQUERY PARAMS: <redacted keys: \(queryParameters.keys.sorted())>")
            }
            
        }
        
        if let params = body.jsonParameters,
           !params.isEmpty {
            
            if includeSensitiveData {
                customLog.append("\nPARAMETERS: \(params)")
            }
            else {
                customLog.append("\nPARAMETERS: <redacted keys: \(params.keys.sorted())>")
            }
            
        }
        
        if !includeSensitiveData {
            customLog.append("\nSENSITIVE PAYLOAD LOGGING: Disabled")
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

//
//  APIServiceProtocol.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 7/13/24.
//

import Foundation

protocol APIProtocol: AnyObject, Sendable, Loggable {

    var environment: AppEnvironment? { get }
    var hostURL: String { get }
    var accessToken: String? { get set }
    var networkSession: URLSession { get }
    var requestTimeout: TimeInterval { get }
    var resourceTimeout: TimeInterval { get }
    var retryPolicy: APIRetryPolicy { get }

    func freshAccessToken() async throws(APIError) -> String?

}

protocol APIServiceProtocol: APIProtocol {

    var accessToken: String? { get set }
    var deviceToken: String? { get }
    var environment: AppEnvironment? { get }
    var hostURL: String { get }

    // Health

    @concurrent func getHealth() async throws

    // Device

    @concurrent func registerDevice(token: String, userId: String) async throws
    @concurrent func signOutCustomerDevice(installationId: String) async throws

    // Users

    @concurrent func getUser(id: String) async throws -> LLUser
    @concurrent func getUserProfile() async throws -> LLUser
    @concurrent func updateUser(user: LLUser) async throws
    @concurrent func createUser(user: LLUser) async throws -> LLUser
    @concurrent func deleteUser(user: LLUser) async throws

    // Customer launch and catalog

    @concurrent func getCustomerBootstrap(appKey: String) async throws -> CustomerBootstrap
    @concurrent func getCustomerLocation(businessId: String, locationId: String) async throws -> CustomerLocationDetails
    @concurrent func getCustomerCategories(locationId: String) async throws -> [ProductCategory]
    @concurrent func getCustomerProducts(locationId: String, query: ProductQuery) async throws -> CustomerPage<Product>
    @concurrent func getCustomerProduct(locationId: String, productId: String) async throws -> Product
    @concurrent func getCustomerPromotions(locationId: String) async throws -> [Promotion]
    @concurrent func getCustomerEvents(locationId: String, offset: Int, limit: Int) async throws -> CustomerPage<StoreEvent>

    // Customer account and loyalty

    @concurrent func getCustomerAccount() async throws -> CustomerAccount
    @concurrent func registerCustomerAccount(storeId: String, displayName: String) async throws -> CustomerAccount
    @concurrent func updateCustomerAccount(displayName: String) async throws -> CustomerAccount
    @concurrent func deleteCustomerAccount() async throws
    @concurrent func getCustomerMembership(locationId: String) async throws -> CustomerLocationMembership
    @concurrent func joinCustomerMembership(locationId: String) async throws -> CustomerLocationMembership
    @concurrent func getCustomerLoyaltyHistory(locationId: String, offset: Int) async throws -> CustomerPage<LoyaltyHistoryEntry>

    // Customer age policy

    @concurrent func getCustomerAgeGateAcceptance(locationId: String) async throws -> AgeGateAcceptance?
    @concurrent func acceptCustomerAgeGate(locationId: String, policy: EffectiveAgePolicy) async throws -> AgeGateAcceptance

}

extension APIProtocol {

    func buildRequest(method: HTTPRequestMethod,
                      apiPath: APIPath,
                      queryParameters: [String: String] = [:],
                      parameters: [String: Any] = [:],
                      headers: [String: String] = [:],
                      retryPolicy: APIRetryPolicy? = nil,
                      requiresAuthentication: Bool = true) async throws(APIError) -> Data {

        var apiLogResponse: APILogResponse?

        defer {

            if let apiLogResponse {
                APILogResponseStore.shared.append(apiLogResponse)
            }

        }

        let accessToken = try await accessTokenIfNeeded(requiresAuthentication: requiresAuthentication)
        guard !Task.isCancelled else { throw APIError.unknownError }

        let request = try makeRequest(
            method: method,
            apiPath: apiPath,
            queryParameters: queryParameters,
            body: .json(parameters),
            accessToken: accessToken,
            headers: headers
        )

        let (data, response, attemptCount) = try await performRequestWithRetry(
            request: request,
            method: method,
            path: apiPath.path.buildURL,
            retryPolicy: retryPolicy ?? self.retryPolicy
        )

        apiLogResponse = APILogResponse(
            method: method.rawValue,
            path: request.url?.absoluteString ?? "No URL Provided",
            statusCode: (response as? HTTPURLResponse)?.statusCode ?? -1,
            headers: request.allHTTPHeaderFields ?? [:],
            queryParameters: queryParameters,
            body: parameters,
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
                               data: Data,
                               retryPolicy: APIRetryPolicy? = nil,
                               requiresAuthentication: Bool = true) async throws(APIError) -> Data {

        var apiLogResponse: APILogResponse?

        defer {

            if let apiLogResponse {
                APILogResponseStore.shared.append(apiLogResponse)
            }

        }

        let accessToken = try await accessTokenIfNeeded(requiresAuthentication: requiresAuthentication)
        guard !Task.isCancelled else { throw APIError.unknownError }

        let request = try makeRequest(
            method: method,
            apiPath: apiPath,
            queryParameters: [:],
            body: .multipart(boundary: boundary, data: data),
            accessToken: accessToken
        )

        let (data, response, attemptCount) = try await performRequestWithRetry(
            request: request,
            method: method,
            path: apiPath.path.buildURL,
            retryPolicy: retryPolicy ?? self.retryPolicy
        )

        apiLogResponse = APILogResponse(
            method: method.rawValue,
            path: request.url?.absoluteString ?? "No URL Provided",
            statusCode: (response as? HTTPURLResponse)?.statusCode ?? -1,
            headers: request.allHTTPHeaderFields ?? [:],
            queryParameters: [:],
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

    private func accessTokenIfNeeded(requiresAuthentication: Bool) async throws(APIError) -> String? {

        guard requiresAuthentication else { return nil }
        guard let accessToken = try await freshAccessToken(),
              !accessToken.isEmpty else {
            throw .missingAccessToken
        }

        return accessToken

    }

}

extension APIProtocol {

    private func performRequestWithRetry(request: URLRequest,
                                         method: HTTPRequestMethod,
                                         path: String,
                                         retryPolicy: APIRetryPolicy) async throws(APIError) -> (Data, URLResponse, Int) {

        var attempt = 0
        var latestResponse: (Data, URLResponse)?

        while attempt < retryPolicy.maxAttempts {

            attempt += 1

            do {

                let response = try await self.networkSession.data(for: request)
                latestResponse = response

                if let httpResponse = response.1 as? HTTPURLResponse,
                   retryPolicy.shouldRetry(
                       statusCode: httpResponse.statusCode,
                       attempt: attempt,
                       method: method
                   ) {

                    self.log(
                        level: .info,
                        message: """
                        Retrying API request after status code \(httpResponse.statusCode)
                        Attempt: \(attempt)
                        Path: \(path)
                        """
                    )

                    do {
                        try await Task.sleep(nanoseconds: retryPolicy.delayNanoseconds(for: attempt))
                    }
                    catch {
                        throw self.mapToAPIError(error)
                    }
                    continue

                }

                return (response.0, response.1, attempt)

            }
            catch {

                guard retryPolicy.shouldRetry(
                    error: error,
                    attempt: attempt,
                    method: method
                ) else {

                    self.logError(
                        title: "API Request Failed",
                        message: """
                        Method: \(method.rawValue.uppercased())
                        Attempt: \(attempt)
                        Path: \(path)
                        Error: \(error.getMessageForError())
                        """
                    )

                    let apiError = self.mapToAPIError(error)
                    throw apiError

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

                do {
                    try await Task.sleep(nanoseconds: retryPolicy.delayNanoseconds(for: attempt))
                }
                catch {
                    throw self.mapToAPIError(error)
                }

            }

        }

        if let latestResponse {
            return (latestResponse.0, latestResponse.1, attempt)
        }

        throw APIError.unknownError

    }

    @concurrent
    func parseData<T: Decodable>(data: Data) async throws(APIError) -> T {

        do {

            let responseDecoder = JSONDecoder()
            responseDecoder.dateDecodingStrategy = .custom { decoder in

                let container = try decoder.singleValueContainer()
                let dateString = try container.decode(String.self)

                let fractionalSecondsFormatter = ISO8601DateFormatter()
                fractionalSecondsFormatter.formatOptions = [
                    .withInternetDateTime,
                    .withFractionalSeconds
                ]

                if let date = fractionalSecondsFormatter.date(from: dateString) {
                    return date
                }

                let formatter = ISO8601DateFormatter()

                if let date = formatter.date(from: dateString) {
                    return date
                }

                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Expected ISO-8601 date string."
                )

            }
            return try responseDecoder.decode(T.self, from: data)

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
                message: "Unknown error: \(await error.getMessageForError())"
            )

        }

        throw APIError.decodingError

    }

    private func handleErrorResponse(data: Data,
                                     response: URLResponse) -> APIError? {

        guard let httpResponse = response as? HTTPURLResponse else {
            return nil
        }

        let statusCode = httpResponse.statusCode
        let badStatusCodes = 400...599

        guard badStatusCodes.contains(statusCode) else {
            return nil
        }

        let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        let zodErrorMessage = zodErrorDescription(errorJson)

        let decodedError = try? JSONDecoder().decode(
            APIErrorResponse.self,
            from: data
        )

        let message = zodErrorMessage
            ?? decodedError?.message
            ?? "We don't know what went wrong, but it did!"

        self.logError(
            title: "API Service Error",
            message: message
        )

        if let platformError = decodedError?.metadata {
            return .platformError(platformError)
        }

        return .serverError(
            statusCode: statusCode,
            errorMessage: message
        )

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

    private func mapToAPIError(_ error: Error) -> APIError {

        if let apiError = error as? APIError {
            return apiError
        }

        if error is DecodingError {
            return .decodingError
        }

        if let urlError = error as? URLError,
           urlError.code == .badURL {
            return .badURL
        }

        return .unknownError

    }

}

extension APIProtocol {

    func makeRequest(method: HTTPRequestMethod,
                     apiPath: APIPath,
                     queryParameters: [String: String],
                     body: RequestBody,
                     accessToken: String?,
                     headers: [String: String] = [:]) throws(APIError) -> URLRequest {

        guard !self.hostURL.isEmpty else {
            throw APIError.serverError(statusCode: 503, errorMessage: "The API URL is not configured for this app target.")
        }

        guard let baseComponents = URLComponents(string: self.hostURL),
              let scheme = baseComponents.scheme?.lowercased(),
              ["http", "https"].contains(scheme),
              let host = baseComponents.host, !host.isEmpty,
              baseComponents.user == nil,
              baseComponents.password == nil,
              baseComponents.query == nil,
              baseComponents.fragment == nil,
              var urlComponents = URLComponents(string: "\(self.hostURL)/\(apiPath.path.buildURL)") else {
            throw APIError.badURL
        }

        if !queryParameters.isEmpty {
            urlComponents.queryItems = queryParameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        }

        guard let url = urlComponents.url else {
            throw APIError.badURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.timeoutInterval = self.requestTimeout
        request.setValue(Self.appVersion, forHTTPHeaderField: "App-Version")

        for (name, value) in headers {
            request.setValue(value, forHTTPHeaderField: name)
        }

        if let accessToken,
           !accessToken.isEmpty {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }

        switch body {
        case .none:
            break

        case .json(let parameters):

            if !parameters.isEmpty {

                do {
                    request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
                }
                catch {
                    throw APIError.unknownError
                }
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

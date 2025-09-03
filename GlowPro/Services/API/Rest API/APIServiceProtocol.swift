//
//  APIServiceProtocl.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 7/13/24.
//

import Foundation

protocol APIProtocol: AnyObject, Sendable, Loggable {
    
    var environment: AppEnvironment? { get }
    var hostURL: String { get }
    var accessToken: String? { get }
    
}

protocol APIServiceProtocol: APIProtocol {
    
    var accessToken: String? { get }
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
    
    // Business
    
    func getBusinesses() async throws -> [Business]
    func getBusiness(id: String) async throws -> Business
    func createBusiness(business: Business) async throws -> Business
    func updateBusiness(business: Business) async throws
    func deleteBusiness(id: String) async throws
    
    // Locations
    
    func getLocations() async throws -> [Location]
    func getLocations(businessId: String) async throws -> [Location]
    func getLocation(id: String) async throws -> Location
    func createLocation(location: Location) async throws -> Location
    func updateLocation(location: Location) async throws
    func deleteLocation(id: String) async throws
    
    // Workspaces
    
    func getWorkspaces() async throws -> [Workspace]

    // Employees
    
    func getEmployees(businessId: String) async throws -> [Employee]
    func getEmployees(locationId: String) async throws -> [Employee]
    func getEmployeeByUserIdForLocation(userId: String, locationId: String) async throws -> String
    func getEmployee(id: String) async throws -> Employee
    func createEmployee(employee: Employee) async throws -> Employee
    func updateEmployee(employee: Employee) async throws
    func deleteEmployee(id: String) async throws
    
    // Employee Invites
    
    func getEmployeeInvites(businessId: String) async throws -> [EmployeeInvite]
    func getPendingInvitesForUser() async throws -> [EmployeeInvite]
    func acceptEmployeeInvite(invite: EmployeeInvite) async throws
    func declineEmployeeInvite(invite: EmployeeInvite) async throws
    
    func createEmployeeInvite(invite: EmployeeInvite) async throws
    func deleteEmployeeInvite(invite: EmployeeInvite) async throws
    
    // Clients
    
    func getClients(businessId: String) async throws -> [Client]
    func getClients(locationId: String) async throws -> [Client]
    func getClients(employeeId: String) async throws -> [Client]
    func getClient(id: String) async throws -> Client
    func createClient(client: Client, locationId: String) async throws
    func updateClient(client: Client) async throws
    func deleteClient(id: String) async throws
    
    // Media
    
    func getMedia(businessId: String,
                  sortingOption: MediaSortingOption?,
                  tags: [MediaTag]) async throws -> [Media]
    
    func getMedia(locationId: String,
                  sortingOption: MediaSortingOption?,
                  tags: [MediaTag]) async throws -> [Media]
    
    func getMedia(clientId: String,
                  sortingOption: MediaSortingOption?,
                  tags: [MediaTag]) async throws -> [Media]
    
    func favoriteMedia(mediaId: String) async throws
    func deleteMedia(mediaId: String) async throws
    
    // Media Tags
    
    func getMediaTags() async throws -> [MediaTag]
    func createTag(tag: String) async throws
    func deleteTag(mediaTagId: String) async throws
    
    // Activity
    
    func getActivitiy(businessId: String) async throws -> [Activity]
    func getActivitiy(locationId: String) async throws -> [Activity]
    func getActivitiy(employeeId: String) async throws -> [Activity]
    func getActivitiy(clientId: String) async throws -> [Activity]
    
    // System
    
    func getLegalInformation(context: String) async throws -> [LegalItem]
    func getFrequentlyAskedQuestions() async throws -> [FAQViewModel.FAQItemSection]
    
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
                    apiLogResponses.append(apiLogResponse)
                }
                
            }
            
            guard var urlComponents = URLComponents(string: "\(self.hostURL)/\(apiPath.path.buildURL)") else {
                throw URLError(.badURL)
            }
            
            urlComponents.queryItems = queryParameters?.map { URLQueryItem(name: $0.key, value: $0.value) }
            
            guard let url = urlComponents.url else {
                throw URLError(.badURL)
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = method.rawValue
            request.setValue("1.0.0", forHTTPHeaderField: "App-Version")
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
        let errorMessage = errorJson?["error"] as? String
        let errorDescription = errorJson?["message"] as? String
        
        if let httpResponse = response as? HTTPURLResponse {
            let statusCode = httpResponse.statusCode
            
            let badStatusCodes = 400...599
            
            if badStatusCodes.contains(statusCode) {
                
                let message = errorMessage ?? errorDescription
                
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
    
}

//
//  APIService.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 7/13/24.
//

import UIKit

final class APIService: APIServiceProtocol {
    
    internal let loggerName: String = "API_SERVICE"
    internal let loggerEmoji: String = "🌐"
    
    private let analyticsService: AnalyticsServiceProtocol
    private let environmentProvider: EnvironmentProviding
    private let deviceTokenProvider: DeviceTokenProviding
    private let authTokenProvider: APIAuthTokenProviding
    
    internal let networkSession: URLSession
    internal let requestTimeout: TimeInterval
    internal let resourceTimeout: TimeInterval
    internal let retryPolicy: APIRetryPolicy

    internal var accessToken: String? {
        return self.authTokenProvider.authToken
    }

    internal var deviceToken: String? {
        return self.deviceTokenProvider.deviceToken
    }

    internal var environment: AppEnvironment? {
        return self.environmentProvider.environment
    }
        
    var hostURL: String {
        return Constants.URLs.urlForEnvironment(self.environment ?? .localhost)
    }
    
    func freshAccessToken() async throws(APIError) -> String? {

        do {
            return try await self.authTokenProvider.freshAuthToken()
        }
        catch {

            self.logError(
                title: "Auth Token Refresh Error",
                message: error.getMessageForError()
            )

            throw APIError.unknownError

        }

    }

    init(analyticsService: AnalyticsServiceProtocol,
         environmentProvider: EnvironmentProviding,
         deviceTokenProvider: DeviceTokenProviding,
         authTokenProvider: APIAuthTokenProviding,
         networkSession: URLSession? = nil,
         requestTimeout: TimeInterval = Constants.Runtime.apiRequestTimeout,
         resourceTimeout: TimeInterval = Constants.Runtime.apiResourceTimeout,
         retryPolicy: APIRetryPolicy = .default) {
        
        self.analyticsService = analyticsService
        self.environmentProvider = environmentProvider
        self.deviceTokenProvider = deviceTokenProvider
        self.authTokenProvider = authTokenProvider
        self.requestTimeout = requestTimeout
        self.resourceTimeout = resourceTimeout
        self.retryPolicy = retryPolicy
        
        if let networkSession {
            self.networkSession = networkSession
        }
        else {
            
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = requestTimeout
            configuration.timeoutIntervalForResource = resourceTimeout
            self.networkSession = URLSession(configuration: configuration)
            
        }
        
        self.logInit()
        
    }
    
    deinit {
        
        self.logDeinit()
        
    }
    
}

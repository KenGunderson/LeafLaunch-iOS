//
//  APIService.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 7/13/24.
//

import UIKit
import Combine

final class APIService: APIServiceProtocol {
    
    internal let loggerName: String = "API_SERVICE"
    internal let loggerEmoji: String = "🌐"
    
    private let analyticsService: AnalyticsServiceProtocol
    private let environmentService: EnvironmentServiceProtocol
    private let appDelegateService: AppDelegateServiceProtocol
    private let firebaseService: FirebaseServiceProtocol
    
    internal let networkSession: URLSession
    internal let requestTimeout: TimeInterval
    internal let resourceTimeout: TimeInterval
    internal let retryPolicy: APIRetryPolicy

    internal var accessToken: String?
    internal var deviceToken: String?
    internal var environment: AppEnvironment?

    private var cancelBag: CancelBag!
        
    var hostURL: String {
        return Constants.URLs.urlForEnvironment(self.environment ?? Constants.Runtime.fallbackEnvironment)
    }
    
    func freshAccessToken() async throws(APIError) -> String? {

        do {

            let token = try await self.firebaseService.freshAuthToken()
            self.accessToken = token
            return token

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
         environmentService: EnvironmentServiceProtocol,
         appDelegateService: AppDelegateServiceProtocol,
         firebaseService: FirebaseServiceProtocol,
         networkSession: URLSession? = nil,
         requestTimeout: TimeInterval = Constants.Runtime.apiRequestTimeout,
         resourceTimeout: TimeInterval = Constants.Runtime.apiResourceTimeout,
         retryPolicy: APIRetryPolicy = .default) {
        
        self.analyticsService = analyticsService
        self.environmentService = environmentService
        self.appDelegateService = appDelegateService
        self.firebaseService = firebaseService
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
        bindSubscribers()
        
    }
    
    deinit {
        
        self.logDeinit()
        
    }
    
    private func bindSubscribers() {

        self.cancelBag = CancelBag()

        self.appDelegateService
            .deviceTokenPublisher
            .receiveOnMain()
            .sink { [weak self] deviceToken in

                self?.log(message: "Device token: \(deviceToken ?? "NIL")")
                self?.deviceToken = deviceToken

            }
            .store(in: &self.cancelBag)

        self.environmentService
            .environmentPublisher
            .receiveOnMain()
            .sink { [weak self] environment in

                self?.log(message: "Environment: \(environment?.displayName ?? "NIL")")
                self?.environment = environment

            }
            .store(in: &self.cancelBag)

        self.firebaseService
            .currentAccessTokenPublisher
            .receiveOnMain()
            .sink { [weak self] firebaseAccessToken in

                self?.log(message: "Firebase token: \(firebaseAccessToken ?? "NIL")")
                self?.accessToken = firebaseAccessToken

            }
            .store(in: &self.cancelBag)

    }

}

//
//  APIService.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 7/13/24.
//

import UIKit
import Combine

final class APIService: APIServiceProtocol {
    
    private let analyticsService: AnalyticsServiceProtocol
    private let environmentService: EnvironmentServiceProtocol
    private let appDelegateService: AppDelegateServiceProtocol
    private let firebaseService: FirebaseServiceProtocol
    
    internal var accessToken: String?
    internal var deviceToken: String?
    internal var environment: AppEnvironment?
    
    private var cancelBag: CancelBag!
    
    internal let logger = RuneLogger.service(.API)
    
    var hostURL: String {
        return Constants.URLs.urlForEnvironment(self.environment ?? .localhost)
    }
    
    init(analyticsService: AnalyticsServiceProtocol,
         environmentService: EnvironmentServiceProtocol,
         appDelegateService: AppDelegateServiceProtocol,
         firebaseService: FirebaseServiceProtocol) {
        
        self.analyticsService = analyticsService
        self.environmentService = environmentService
        self.appDelegateService = appDelegateService
        self.firebaseService = firebaseService
        
        self.logger.logInit()
        bindSubscribers()
        
    }
    
    deinit {
        
        self.logger
            .logDeinit()
        
    }
    
    private func bindSubscribers() {
        
        self.cancelBag = CancelBag()
        
        self.appDelegateService
            .deviceTokenPublisher
            .receiveOnMain()
            .sink { [weak self] deviceToken in
                
                self?.logger.debugMessage("Device token: \(deviceToken ?? "NIL")")
                self?.deviceToken = deviceToken
                
            }
            .store(in: &self.cancelBag)
        
        self.environmentService
            .environmentPublisher
            .receiveOnMain()
            .sink { [weak self] environment in
                
                self?.logger.debugMessage("Environment: \(environment?.displayName ?? "NIL")")
                self?.environment = environment
                
            }
            .store(in: &self.cancelBag)
        
        self.firebaseService
            .currentAccessTokenPublisher
            .receiveOnMain()
            .sink { [weak self] firebaseAccessToken in
                
                self?.logger.debugMessage("Firebase token: \(firebaseAccessToken ?? "NIL")")
                self?.accessToken = firebaseAccessToken
                
            }
            .store(in: &self.cancelBag)
                
    }
    
}

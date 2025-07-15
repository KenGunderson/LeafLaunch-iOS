//
//  ActiveEntityService.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 7/15/25.
//

import Combine

final class ActiveDestinationService: ActiveDestinationServiceProtocol {    
    
    internal let loggerName: String = "ACTIVE_DESTINATION_SERVICE"
    internal let loggerEmoji: String = "🛩️"
    
    private let apiService: APIServiceProtocol!
    private let analyticsService: AnalyticsServiceProtocol!
    
    @Published private(set) var activeDestination: ActiveDestination?
    var activeDestinationPublisher: AnyPublisher<ActiveDestination?, Never> {
        return self.$activeDestination.eraseToAnyPublisher()
    }
    
    init(apiService: APIServiceProtocol,
         analyticsService: AnalyticsServiceProtocol) {
        
        self.apiService = apiService
        self.analyticsService = analyticsService
        self.logInit()
        
    }
    
    deinit {
        self.logDeinit()
    }
    
    func setActiveDestination(_ destination: ActiveDestination) {
        
        self.activeDestination = destination
        self.log(message: "Set active destination: \(destination)")
        
    }
    
    func removeActiveDestination() {
        
        self.activeDestination = nil
        self.log(message: "Set active destination to NIL")
        
    }
    
    func logout() {
        
        self.activeDestination = nil
        self.log(message: "Set active destination to NIL")
        
    }
    
}

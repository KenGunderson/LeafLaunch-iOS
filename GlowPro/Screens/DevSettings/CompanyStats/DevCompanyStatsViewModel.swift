//
//  DevCompanyStatsViewModel.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 12/31/25.
//

import SwiftUI
import Combine

final class DevCompanyStatsViewModel: ViewModel {
    
    internal let loggerName: String = "DEV"
    internal let loggerEmoji: String = "🔧"
    
    private let alertService: AlertServiceProtocol
    private let apiService: APIServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let authService: AuthServiceProtocol
    private let viewLifecycleService: ViewLifecycleServiceProtocol
    private let environmentService: EnvironmentServiceProtocol
    
    @Published private(set) var companyStats: CompanyStats?
    @Published var selectedInterval: CompanyStatInterval? = .days7
    
    private var navigationService: NavigationService?
    private var cancelBag: CancelBag!
    
    init(alertService: AlertServiceProtocol,
         apiService: APIServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         authService: AuthServiceProtocol,
         viewLifecycleService: ViewLifecycleServiceProtocol,
         environmentService: EnvironmentServiceProtocol) {
        
        self.alertService = alertService
        self.apiService = apiService
        self.analyticsService = analyticsService
        self.authService = authService
        self.viewLifecycleService = viewLifecycleService
        self.environmentService = environmentService
        
        bindSubscribers()
        self.logInit()
        
    }
    
    deinit {
        self.logDeinit()
    }
    
    func setup(navigationService: NavigationService) {
        self.navigationService = navigationService
    }
    
    func loadData() {
        
        self.alertService
            .showAlert(.init(.simpleLoadingIndicator))
        
        Task {
            
            do {
                
                let stats = try await self.apiService.getCompanyStats(
                    interval: self.selectedInterval ?? .days7
                )
                
                await MainActor.run {
                    self.companyStats = stats
                }
                
            } catch {
                
                self.alertService
                    .showAlert(.init(.appAlert(.error(
                        message: error.getMessageForError(),
                        action: {
                            
                            self.navigationService?
                                .popWithDelay()
                            
                        }))))
                
            }
            
        }
        
        self.alertService
            .dismissLoadingIndicator()
        
    }
    
    func dismiss() {
        
        self.navigationService?
            .pop()
        
    }

    private func bindSubscribers() {
        self.cancelBag = CancelBag()
    }
    
}

extension DevCompanyStatsViewModel {
    
    func track() {
        self.analyticsService.track(screen: .devSettings(.companyStats))
    }
    
}

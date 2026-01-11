//
//  FeatureRequestViewModel.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 9/12/25.
//

import SwiftUI
import Combine

final class FeatureRequestViewModel: ViewModel {
    
    internal let loggerName: String = "FEATURE_REQUEST_VIEW_MODEL"
    internal let loggerEmoji: String = "⚙️"
    
    private let apiService: APIServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let authService: AuthServiceProtocol
    private let alertService: AlertServiceProtocol
    private let viewLifecycleService: ViewLifecycleServiceProtocol
    private let environmentService: EnvironmentServiceProtocol
    
    private weak var navigationService: NavigationService?
    
    @Published var featureRequestText: String = ""
    
    private var cancelBag: CancelBag!
        
    init(apiService: APIServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         authService: AuthServiceProtocol,
         alertService: AlertServiceProtocol,
         viewLifecycleService: ViewLifecycleServiceProtocol,
         environmentService: EnvironmentServiceProtocol) {
        
        self.apiService = apiService
        self.analyticsService = analyticsService
        self.authService = authService
        self.alertService = alertService
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
    
    func dismiss() {
        
        self.navigationService?
            .pop()
        
    }
    
    func submit() {
        
        guard let authUser = self.authService.currentUser else { return }
        
        self.alertService
            .showAlert(.init(.simpleLoadingIndicator))
        
        Task {
            
            do {
                
//                _ = try await self.apiService
//                    .submitFeatureRequest(
//                        userId: authUser.id,
//                        request: self.featureRequestText
//                    )
                
                self.alertService
                    .showAlert(.init(.appAlert(.success(
                        message: "Request Submitted Successfully!",
                        action: {
                            self.navigationService?.popWithDelay()
                        }
                    ))))
                
            }
            catch {
                
                self.alertService.showAlert(.init(
                    .appAlert(
                        .error(
                            message: Constants.Message.errorMessage(context: .create, "feature request"),
                            action: {})
                    ))
                )
                
            }
            
            self.alertService.dismissLoadingIndicator()
            
        }
        
    }

    private func bindSubscribers() {
        self.cancelBag = CancelBag()
    }
    
}

extension FeatureRequestViewModel {
    
    func track() {
        self.analyticsService.track(screen: .settings(.featureRequest))
    }
    
}

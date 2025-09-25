//
//  SecurityViewModel.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 9/20/25.
//

import SwiftUI
import Combine

final class SecurityViewModel: ViewModel {
    
    internal let loggerName: String = "SECURITY_VIEW_MODEL"
    internal let loggerEmoji: String = "⚙️"
    
    private let apiService: APIServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let authService: AuthServiceProtocol
    private let alertService: AlertServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol
    private let viewLifecycleService: ViewLifecycleServiceProtocol
    private let environmentService: EnvironmentServiceProtocol
    private var navigationService: NavigationService?
    
    @Published private(set) var isLoading: Bool = true
    @Published private(set) var businessPin: String = ""
    
    private(set) var businessId: String?
    private var cancelBag: CancelBag!
    
    var hasBusinessPin: Bool {
        return !self.businessPin.isEmpty
    }
        
    init(apiService: APIServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         authService: AuthServiceProtocol,
         alertService: AlertServiceProtocol,
         userDefaultsService: UserDefaultsServiceProtocol,
         viewLifecycleService: ViewLifecycleServiceProtocol,
         environmentService: EnvironmentServiceProtocol) {
        
        self.apiService = apiService
        self.analyticsService = analyticsService
        self.authService = authService
        self.alertService = alertService
        self.userDefaultsService = userDefaultsService
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
    
    func loadDataIfNeeded() {
        
        if let businessId {
            
            self.businessPin = self.userDefaultsService
                .getSecurityPinForBusinessId(businessId) ?? ""
            
        }
        else {
            loadData()
        }

    }
    
    private func loadData() {
        
        self.isLoading = true
        
        self.alertService
            .showAlert(.init(.simpleLoadingIndicator))

        Task {
            
            do {
                
                let workspaces = try await self.apiService
                    .getWorkspaces(userId: self.authService.currentUser?.id ?? "")
                
                await MainActor.run { [weak self] in
                    
                    if let myBusiness = workspaces.filter({ $0.isOwner }).first {
                        
                        self?.businessId = myBusiness.id
                        self?.businessPin = self?.userDefaultsService
                            .getSecurityPinForBusinessId(myBusiness.id) ?? ""
                        
                    }
                    
                    self?.isLoading = false
                    
                }
                
            }
            catch {
                
                self.alertService.showAlert(.init(
                    .appAlert(
                        .error(
                            message: Constants.Message.errorMessage("workspaces"),
                            action: {
                                
                                self.navigationService?
                                    .popWithDelay()
                                
                            })
                    ))
                )
                
            }
            
            self.alertService
                .dismissLoadingIndicator()
            
        }
        
    }
    
    func removePin() {
        
        guard let businessId else { return }
        
        self.userDefaultsService
            .set(securityPin: nil, businessId: businessId)
        
        self.loadDataIfNeeded()
        
    }
    
    func dismiss() {
        
        self.navigationService?
            .pop()
        
    }

    private func bindSubscribers() {
        self.cancelBag = CancelBag()
    }
    
}

extension SecurityViewModel {
    
    func track() {
        self.analyticsService.track(screen: .settings(.security))
    }
    
}

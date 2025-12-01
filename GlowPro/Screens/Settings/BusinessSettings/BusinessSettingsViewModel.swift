//
//  BusinessSettingsViewModel.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 9/20/25.
//

import SwiftUI
import Combine

final class BusinessSettingsViewModel: ViewModel {
    
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
    
    @Published var shouldHideScreenshots: Bool = false
    @Published var shouldReportScreenshots: Bool = false
    @Published var allowsOverages: Bool = false
    @Published private(set) var firstHideScreenshotUpdate: Bool = true
    
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
    
    func loadData() {

        Task {
            
            await MainActor.run {
                
                self.isLoading = true
                
                self.alertService
                    .showAlert(.init(.simpleLoadingIndicator))
                
            }
            
            do {
                
                let workspaces = try await self.apiService
                    .getWorkspaces(userId: self.authService.currentUser?.id ?? "")
                
                var businessSettings: BusinessSetting?
                
                if let myBusiness = workspaces.filter({ $0.isOwner }).first {
                    
                    businessSettings = try await self.apiService
                        .getBusinessSettings(businessId: myBusiness.id)
                    
                }
                
                await MainActor.run { [weak self, businessSettings] in
                    
                    if let myBusiness = workspaces.filter({ $0.isOwner }).first {
                        
                        self?.businessId = myBusiness.id
                        self?.businessPin = self?.userDefaultsService.getSecurityPinForBusinessId(myBusiness.id) ?? ""
                        self?.shouldHideScreenshots = self?.userDefaultsService.shouldHideScreenshots ?? false
                        self?.shouldReportScreenshots = businessSettings?.shouldReportScreenshot ?? false
                        self?.allowsOverages = businessSettings?.allowsOverages ?? false
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self?.firstHideScreenshotUpdate = false
                        }
                        
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
        
        self.loadData()
        
    }
    
    func dismiss() {
        
        self.navigationService?
            .pop()
        
    }
    
    func set(shouldHideScreenshots: Bool) {
        
        self.userDefaultsService
            .set(shouldHideScreenshots: shouldHideScreenshots)
        
        self.alertService
            .showAlert(.init(.appAlert(.init(
                title: "One More Step!",
                message: "To finish setting up this feature, please restart your app.",
                primaryButtonTitle: "Okay",
                primaryButtonAction: {}
            ))))
        
    }
    
    func set(shouldReportScreenshots: Bool) {
        
        guard let businessId else { return }
        
        Task {
            
            try await self.apiService
                .updateShouldReportScreenshot(
                    businessId: businessId,
                    shouldReportScreenshot: shouldReportScreenshots
                )
            
        }
        
    }
    
    func set(allowsOverages: Bool) {
        
        guard let businessId else { return }
        
        Task {
            
            try await self.apiService
                .updateAllowsOverages(
                    businessId: businessId,
                    allowsOverages: allowsOverages
                )
            
        }
        
    }

    private func bindSubscribers() {
        
        self.cancelBag = CancelBag()
        
        self.userDefaultsService
            .shouldHideScreenshotsPublisher
            .sink { [weak self] shouldHide in
                
                guard shouldHide != self?.shouldHideScreenshots else { return }
                self?.shouldReportScreenshots = shouldHide
                
            }
            .store(in: &self.cancelBag)
        
    }
    
}

extension BusinessSettingsViewModel {
    
    func track() {
        self.analyticsService.track(screen: .settings(.businessSettings))
    }
    
}

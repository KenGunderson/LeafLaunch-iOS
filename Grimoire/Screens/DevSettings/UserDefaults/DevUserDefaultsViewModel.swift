//
//  DevUserDefaultsViewModel.swift
//  Grimoire 
//
//  Created by Sako Hovaguimian on 7/16/24.
//

import SwiftUI
import Combine

final class DevUserDefaultsViewModel: ViewModel {
    
    internal let loggerName: String = "DEV"
    internal let loggerEmoji: String = "🔧"
    
    private let alertService: AlertServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let authService: AuthServiceProtocol
    private let viewLifecycleService: ViewLifecycleServiceProtocol
    private let environmentService: EnvironmentServiceProtocol
    private(set) var permissionService: PermissionsServiceProtocol
    public var userDefaultsService: UserDefaultsServiceProtocol
    
    @Published var sheet: Sheet?
    @Published var fullScreenCover: FullScreenCover?
    
    @Published var theme: AvailableTheme!
    @Published var didCompleteOnboarding: Bool!
    @Published var didShowPermissionScreen: Bool!
    @Published var didViewChecklistCompletionSheet: Bool!
    @Published var didCompletePermission: Bool!
    @Published var didRateMyAppAlertShow: Bool!
    @Published var shouldHideScreenshots: Bool!

    @Published var shouldShowNoNetworkError: Bool = false
    @Published var shouldShowHealthCheckError: Bool = false
    @Published var shouldShowForceUpdateError: Bool = false
    
    @Published var lastViewedWhatsNewVersion: String?
    
    private(set) var impersonatedUserData: Data?
    
    private weak var navigationService: NavigationService?
    private var cancelBag: CancelBag!
    
    init(alertService: AlertServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         authService: AuthServiceProtocol,
         viewLifecycleService: ViewLifecycleServiceProtocol,
         environmentService: EnvironmentServiceProtocol,
         permissionService: PermissionsServiceProtocol,
         userDefaultsService: UserDefaultsServiceProtocol) {
        
        self.alertService = alertService
        self.analyticsService = analyticsService
        self.authService = authService
        self.viewLifecycleService = viewLifecycleService
        self.environmentService = environmentService
        self.permissionService = permissionService
        self.userDefaultsService = userDefaultsService
        
        self.theme = userDefaultsService.theme
        self.didCompleteOnboarding = userDefaultsService.didCompleteOnboarding
        self.didCompletePermission = userDefaultsService.didCompletePermission
        self.didViewChecklistCompletionSheet = userDefaultsService.didViewChecklistCompletionSheet
        self.didRateMyAppAlertShow = userDefaultsService.didRateMyAppAlertShow
        self.shouldHideScreenshots = userDefaultsService.shouldHideScreenshots
        self.impersonatedUserData = userDefaultsService.impersonatingUserData
        self.lastViewedWhatsNewVersion = userDefaultsService.lastViewedWhatsNewVersion
        
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
        
    }
    
    func set(theme: AvailableTheme) {
        
        self.theme = theme
        
        self.userDefaultsService
            .set(theme: theme)
        
    }
    
    func dismiss() {
        
        self.navigationService?
            .pop()
        
    }

    private func bindSubscribers() {
        
        self.cancelBag = CancelBag()
        
        self.userDefaultsService
            .impersonatingUserDataPublisher
            .receiveOnMain()
            .sink { [weak self] data in
                self?.impersonatedUserData = data
            }
            .store(in: &self.cancelBag)
        
        self.$didCompleteOnboarding
            .dropFirst()
            .receiveOnMain()
            .sink { [weak self] didCompleteOnboarding in
                
                guard let didCompleteOnboarding else { return }
                self?.userDefaultsService.set(didCompleteOnboarding: didCompleteOnboarding)
                
            }
            .store(in: &self.cancelBag)
        
        self.$didCompletePermission
            .dropFirst()
            .receiveOnMain()
            .sink { [weak self] didCompletePermission in
                
                guard let didCompletePermission else { return }
                self?.userDefaultsService.set(didCompletePermission: didCompletePermission)
                
            }
            .store(in: &self.cancelBag)
        
        self.$didViewChecklistCompletionSheet
            .dropFirst()
            .receiveOnMain()
            .sink { [weak self] didViewChecklistCompletionSheet in
                
                guard let didViewChecklistCompletionSheet else { return }
                self?.userDefaultsService.set(didViewChecklistCompletionSheet: didViewChecklistCompletionSheet)
                
            }
            .store(in: &self.cancelBag)
        
        self.$didRateMyAppAlertShow
            .dropFirst()
            .receiveOnMain()
            .sink { [weak self] didRateMyAppAlertShow in
                
                guard let didRateMyAppAlertShow else { return }
                self?.userDefaultsService.set(didRateMyAppAlertShow: didRateMyAppAlertShow)
                
            }
            .store(in: &self.cancelBag)
        
        self.$shouldHideScreenshots
            .dropFirst()
            .receiveOnMain()
            .sink { [weak self] shouldHideScreenshots in
                
                guard let shouldHideScreenshots else { return }
                self?.userDefaultsService.set(shouldHideScreenshots: shouldHideScreenshots)
                
            }
            .store(in: &self.cancelBag)
        
        self.$shouldShowNoNetworkError
            .dropFirst()
            .receiveOnMain()
            .sink { [weak self] shouldShowNoNetworkError in
                
                guard shouldShowNoNetworkError else { return }
                self?.presentNoNetworkCardView()
                
            }
            .store(in: &self.cancelBag)
        
        self.$shouldShowForceUpdateError
            .dropFirst()
            .receiveOnMain()
            .sink { [weak self] shouldShowForceUpdateError in
                
                guard shouldShowForceUpdateError else { return }
                self?.presentForceUpdateCardView()
                
            }
            .store(in: &self.cancelBag)
        
        self.$shouldShowHealthCheckError
            .dropFirst()
            .receiveOnMain()
            .sink { [weak self] shouldShowHealthCheckError in
                
                guard shouldShowHealthCheckError else { return }
                self?.presentHealthErrorCardView()
                
            }
            .store(in: &self.cancelBag)
        
        self.$lastViewedWhatsNewVersion
            .dropFirst()
            .receiveOnMain()
            .sink { [weak self] lastViewedWhatsNewVersion in
                
                self?.userDefaultsService
                    .set(lastViewedWhatsNewVersion: lastViewedWhatsNewVersion)
                
            }
            .store(in: &self.cancelBag)
        
    }
    
    private func presentNoNetworkCardView() {
        
        withAnimation {
            
            self.alertService
                .showAlert(.init(.enviornmentAlert(.init(config: Constants.NO_NETWORK_ENV_ALERT { [weak self] in
                    
                    self?.shouldShowNoNetworkError = false
                    
                }))))
            
        }
        
    }
    
    private func presentForceUpdateCardView() {
        
        withAnimation {
            
            self.alertService
                .showAlert(.init(.enviornmentAlert(.init(config: Constants.FORCE_UPDATE_ENV_ALERT { [weak self] in
                    
                    self?.shouldShowForceUpdateError = false
                    
                }))))
            
        }
        
    }
    
    private func presentHealthErrorCardView() {
        
        withAnimation {
            
            self.alertService
                .showAlert(.init(.enviornmentAlert(.init(config: Constants.HEALTH_CHECK_ENV_ALERT { [weak self] in
                    
                    self?.shouldShowHealthCheckError = false
                    
                }))))
            
        }
        
    }
    
    func resetDevFlags() {
        
        self.userDefaultsService.resetDevFlags()
        self.didCompleteOnboarding = self.userDefaultsService.didCompleteOnboarding
        self.didCompletePermission = self.userDefaultsService.didCompletePermission
        self.didViewChecklistCompletionSheet = self.userDefaultsService.didViewChecklistCompletionSheet
        self.didRateMyAppAlertShow = self.userDefaultsService.didRateMyAppAlertShow
        self.shouldHideScreenshots = self.userDefaultsService.shouldHideScreenshots
        self.lastViewedWhatsNewVersion = self.userDefaultsService.lastViewedWhatsNewVersion
        
    }
    
}

extension DevUserDefaultsViewModel {
    
    func track() {
        self.analyticsService.track(screen: .devSettings(.userDefaults))
    }
    
}

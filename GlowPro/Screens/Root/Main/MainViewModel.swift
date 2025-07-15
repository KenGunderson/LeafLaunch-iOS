//
//  MainViewModel.swift
//  GlowPro 
//
//  Created by Sako Hovaguimian on 7/15/24.
//

import SwiftUI
import Combine

final class MainViewModel: ViewModel {
    
    internal let loggerName: String = "MAIN_VIEW_MODEL"
    internal let loggerEmoji: String = "🫚"
    
    private let appDelegateService: AppDelegateServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let firebaseService: FirebaseServiceProtocol
    private let authService: AuthServiceProtocol
    private let activeDestination: ActiveDestinationServiceProtocol
    private(set) var userDefaultsService: UserDefaultsServiceProtocol
    private let viewLifecycleService: ViewLifecycleServiceProtocol
    private let pushNotificationsService: PushNotificationServiceProtocol
    private let permissionsService: PermissionsServiceProtocol

    private(set) var tabBarNavigationService: TabBarNavigationService?
    private var cancelBag: CancelBag!
    
    @Published private(set) var shouldShowTabBarScreen: Bool = false
    @Published private(set) var shouldShowWelcomeScreen: Bool = false
    @Published private(set) var shouldShowActiveDestinationSelectionSheet: Bool = false
        
    // ViewModels
    
    private(set) var welcomeViewModel = globalResolver.resolve(WelcomeViewModel.self)!
    private(set) var tab1ViewModel = globalResolver.resolve(Tab1ViewModel.self)!
    private(set) var tab2ViewModel = globalResolver.resolve(Tab2ViewModel.self)!
    private(set) var tab3ViewModel = globalResolver.resolve(Tab3ViewModel.self)!
    private(set) var tab4ViewModel = globalResolver.resolve(Tab4ViewModel.self)!
    
    // Tab Bar Properties
    
    init(appDelegateService: AppDelegateServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         firebaseService: FirebaseServiceProtocol,
         authService: AuthServiceProtocol,
         activeDestination: ActiveDestinationServiceProtocol,
         userDefaultsService: UserDefaultsServiceProtocol,
         viewLifecycleService: ViewLifecycleServiceProtocol,
         pushNotificationsService: PushNotificationServiceProtocol,
         permissionsService: PermissionsServiceProtocol) {
        
        self.appDelegateService = appDelegateService
        self.analyticsService = analyticsService
        self.firebaseService = firebaseService
        self.activeDestination = activeDestination
        self.authService = authService
        self.userDefaultsService = userDefaultsService
        self.viewLifecycleService = viewLifecycleService
        self.pushNotificationsService = pushNotificationsService
        self.permissionsService = permissionsService
        
        self.logInit()
        bindSubscribers()
        
    }
    
    deinit {
        self.logDeinit()
    }
    
    func setup(tabBarNavigationService: TabBarNavigationService) {
        self.tabBarNavigationService = tabBarNavigationService
    }
    
    func track(tab: Tab) {
        
        self.analyticsService
            .track(.main(.tabIntent(tab: tab)))
        
    }
    
    private func bindSubscribers() {
        
        self.cancelBag = CancelBag()
        
        Publishers
            .CombineLatest(
                self.authService.currentUserPublisher,
                self.firebaseService.userPublisher
            )
            .receiveOnMain()
            .sink { [weak self] authServiceCurrentUser, firebaseUser in
                
                let isUserMissing = authServiceCurrentUser == nil
                let isFirebaseUserMissing = firebaseUser == nil
                let shouldShowWelcomeScreen = isUserMissing && isFirebaseUserMissing
                
                self?.shouldShowTabBarScreen = !isUserMissing
                self?.shouldShowWelcomeScreen = shouldShowWelcomeScreen
                
                // TODO: -
                /// CHECK IF BUSINESS COUNT || LOCATION COUNT > 1 to then show selection
                /// If they have 0 || 1 set the active location to active or nil
                /// Make computed property to check for locations + businesses
                /// Make computed property to check for singleActiveId
                /// `self?.shouldShowActiveDestinationSelectionSheet = {ETC})`
                
                if !isUserMissing && !isFirebaseUserMissing {
                    self?.presentModalsIfNeeded()
                }
                
            }
            .store(in: &self.cancelBag)
        
        self.appDelegateService
            .onNotificationPublisher
            .receiveOnMain()
            .sink {[weak self]  notification in
                
                guard let notification else { return }
                
                self?.pushNotificationsService
                    .parsePushNotification(
                        notification,
                        isTapped: false
                    )
                
            }
            .store(in: &self.cancelBag)
        
        self.appDelegateService
            .onTappedNotificationPublisher
            .receiveOnMain()
            .sink {[weak self] notification in
                
                guard let notification else { return }
                
                self?.pushNotificationsService
                    .parsePushNotification(
                        notification,
                        isTapped: true
                    )
                
            }
            .store(in: &self.cancelBag)
        
    }
    
    private func presentModalsIfNeeded() {
                
       self.tabBarNavigationService?.resetPathItems()
        
        let shouldShowOnboarding = !self.userDefaultsService.didCompleteOnboarding
        
        if shouldShowOnboarding {
            
            self.logger.debug("Attemping to show onboarding modal")
            
            self.tabBarNavigationService?
                .currentNavigationService()
                .modal(fullScreenCover: .onboarding)
            
        }
        
    }
    
}

extension MainViewModel {
    
    func track() {
        self.analyticsService.track(screen: .main)
    }
    
}

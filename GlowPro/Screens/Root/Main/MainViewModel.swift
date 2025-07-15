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
    private let activeDestinationService: ActiveDestinationServiceProtocol
    private(set) var userDefaultsService: UserDefaultsServiceProtocol
    private let viewLifecycleService: ViewLifecycleServiceProtocol
    private let pushNotificationsService: PushNotificationServiceProtocol
    private let permissionsService: PermissionsServiceProtocol

    private(set) var tabBarNavigationService: TabBarNavigationService?
    private var cancelBag: CancelBag!
    
    @Published private(set) var shouldShowTabBarScreen: Bool = false
    @Published private(set) var shouldShowWelcomeScreen: Bool = false
        
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
         activeDestinationService: ActiveDestinationServiceProtocol,
         userDefaultsService: UserDefaultsServiceProtocol,
         viewLifecycleService: ViewLifecycleServiceProtocol,
         pushNotificationsService: PushNotificationServiceProtocol,
         permissionsService: PermissionsServiceProtocol) {
        
        self.appDelegateService = appDelegateService
        self.analyticsService = analyticsService
        self.firebaseService = firebaseService
        self.activeDestinationService = activeDestinationService
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
                
                if let user = authServiceCurrentUser,
                   !isFirebaseUserMissing {
                    
                    self?.presentModalsIfNeeded(user: user)
                    
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
        
        self.userDefaultsService
            .didCompleteOnboardingPublisher
            .receiveOnMain()
            .sink { [weak self] didCompleteOnboarding in
                
                guard didCompleteOnboarding else { return }
                
                guard let user = self?.authService.currentUser else { return }
                self?.presentDesintationSelectionIfNeeded(user: user)
                
            }
            .store(in: &self.cancelBag)
        
    }
    
    private func presentModalsIfNeeded(user: GPUser) {
                
       self.tabBarNavigationService?.resetPathItems()
        
        let shouldShowOnboarding = !self.userDefaultsService.didCompleteOnboarding
        
        if shouldShowOnboarding {
            
            self.logger.debug("Attemping to show onboarding modal")
            
            self.tabBarNavigationService?
                .currentNavigationService()
                .modal(fullScreenCover: .onboarding)
            
        } else {
            presentDesintationSelectionIfNeeded(user: user)
        }
        
    }
    
    private func presentDesintationSelectionIfNeeded(user: GPUser) {
                
        let allLocationsFromAllBusinessesCount = user.businesses.flatMap(\.locations).count
        
        if allLocationsFromAllBusinessesCount == 0 {
            return
        }
        
        if allLocationsFromAllBusinessesCount > 1 {
            
            self.tabBarNavigationService?
                .currentNavigationService()
                .modal(sheet: .businessActiveDestinationSelectionScreen)
            
        } else {
            
            if let location = user.businesses.first?.locations.first {
                self.activeDestinationService.setActiveDestination(.location(locationId: location.id))
            }
            
        }
        
    }
    
}

extension MainViewModel {
    
    func track() {
        self.analyticsService.track(screen: .main)
    }
    
}

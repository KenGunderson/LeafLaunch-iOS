//
//  MainViewModel.swift
//  Grimoire 
//
//  Created by Sako Hovaguimian on 7/15/24.
//

import SwiftUI
import Combine
import FactoryKit

final class MainViewModel: ViewModel {
    
    internal let loggerName: String = "MAIN_VIEW_MODEL"
    internal let loggerEmoji: String = "🫚"
    
    private let alertService: AlertServiceProtocol
    private let appDelegateService: AppDelegateServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let firebaseService: FirebaseServiceProtocol
    private let authService: AuthServiceProtocol
    private let viewLifecycleService: ViewLifecycleServiceProtocol
    private let pushNotificationsService: PushNotificationServiceProtocol
    private let permissionsService: PermissionsServiceProtocol
    let userDefaultsService: UserDefaultsServiceProtocol

    private(set) var tabBarNavigationService: TabBarNavigationService?
    private var cancelBag: CancelBag!
    
    @Published private(set) var showShouldHomeScreen: Bool = false
    @Published private(set) var shouldShowWelcomeScreen: Bool = false
    
    var readOnlyAlertService: any AlertServiceProtocol {
        return self.alertService
    }
        
    // ViewModels
    
    @LazyInjected(\.welcomeViewModel) private(set) var welcomeViewModel: WelcomeViewModel
    @LazyInjected(\.tab1ViewModel) private(set) var tab1ViewModel: Tab1ViewModel
    @LazyInjected(\.tab2ViewModel) private(set) var tab2ViewModel: Tab2ViewModel
    @LazyInjected(\.tab3ViewModel) private(set) var tab3ViewModel: Tab3ViewModel
    @LazyInjected(\.tab4ViewModel) private(set) var tab4ViewModel: Tab4ViewModel
    
    // Tab Bar Properties
    
    init(alertService: AlertServiceProtocol,
         appDelegateService: AppDelegateServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         firebaseService: FirebaseServiceProtocol,
         authService: AuthServiceProtocol,
         userDefaultsService: UserDefaultsServiceProtocol,
         viewLifecycleService: ViewLifecycleServiceProtocol,
         pushNotificationsService: PushNotificationServiceProtocol,
         permissionsService: PermissionsServiceProtocol) {
        
        self.alertService = alertService
        self.appDelegateService = appDelegateService
        self.analyticsService = analyticsService
        self.firebaseService = firebaseService
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
    
    var shouldShowOnboarding: Bool {
        
        guard Constants.Feature.isOnboardingEnabled else { return false }
        return !self.userDefaultsService.didCompleteOnboarding
        
    }
    
    var shouldShowWhatsNew: Bool {
        
        guard Constants.Feature.isWhatsNewEnabled else { return false }
        guard let currentItem = Constants.WhatsNewItems.items.last else { return false }
        
        let defaultVersion = "0.0.0"
        let previouslyViewedVersion = SemanticVersion(self.userDefaultsService.lastViewedWhatsNewVersion ?? defaultVersion)
        let currentVersion = currentItem.version
        
        return currentVersion > previouslyViewedVersion
        
    }
    
    func setup(tabBarNavigationService: TabBarNavigationService) {
        self.tabBarNavigationService = tabBarNavigationService
    }
    
    func track(tab: Tab) {
        
        self.analyticsService
            .track(screen: .main(.tabIntent(tab: tab)))
        
    }
    
    private func bindSubscribers() {
        
        self.cancelBag = CancelBag()
        
        Publishers
            .CombineLatest(self.authService.currentUserPublisher, self.firebaseService.userPublisher)
            .filter { authUser, fbUser in
                
                let bothPresent = authUser != nil && fbUser != nil
                let bothMissing = authUser == nil && fbUser == nil
                
                return bothPresent || bothMissing
                
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] authServiceCurrentUser, firebaseUser in
                
                let isUserMissing = authServiceCurrentUser == nil
                let isFirebaseUserMissing = firebaseUser == nil
                let shouldShowWelcomeScreen = isUserMissing && isFirebaseUserMissing
                
                self?.showShouldHomeScreen = !isUserMissing
                self?.shouldShowWelcomeScreen = shouldShowWelcomeScreen
                
                let isLoggedIn = !isUserMissing && !isFirebaseUserMissing
                
                if isLoggedIn {
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                        self?.presentModalsIfNeeded()
                    }
                    
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
            .sink { [weak self] didComplete in
                
                if didComplete {
                    self?.presentModalsIfNeeded()
                }
                
            }
            .store(in: &self.cancelBag)
        
    }
    
    private func presentModalsIfNeeded() {
        
        if self.shouldShowOnboarding {
            
            self.tabBarNavigationService?
                .tab1NavigationService
                .modal(fullScreenCover: .onboarding)
            
            return
            
        }
        
        if self.shouldShowWhatsNew {
            
            Task { @MainActor in
                
                guard let currentItem = Constants.WhatsNewItems.items.last else { return }
                
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                
                self.tabBarNavigationService?
                    .tab1NavigationService
                    .modal(sheet: .whatsNew(currentItem))
                
            }
            
            return
            
        }
        
    }

}

extension MainViewModel {
    
    func track() {
        self.analyticsService.track(screen: .main(.root))
    }
    
}

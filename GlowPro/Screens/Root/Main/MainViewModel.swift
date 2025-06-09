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
         userDefaultsService: UserDefaultsServiceProtocol,
         viewLifecycleService: ViewLifecycleServiceProtocol,
         pushNotificationsService: PushNotificationServiceProtocol,
         permissionsService: PermissionsServiceProtocol) {
        
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
            .sink {[weak self]  notification in
                
                guard let notification else { return }
                
                self?.pushNotificationsService
                    .parsePushNotification(
                        notification,
                        isTapped: true
                    )
                
            }
            .store(in: &self.cancelBag)
        
//        self.userDefaultsService
//            .didCompleteOnboardingPublisher
//            .receiveOnMain()
//            .sink { [weak self] didCompleteOnboarding in
//                
//                guard didCompleteOnboarding else { return }
//                self?.presentModalsIfNeeded()
//                
//            }
//            .store(in: &self.cancelBag)
//        
//        self.userDefaultsService
//            .didCompletePermissionPublisher
//            .receiveOnMain()
//            .sink { [weak self] didCompleteOnboarding in
//                
//                guard didCompleteOnboarding else { return }
//                self?.presentModalsIfNeeded()
//                
//            }
//            .store(in: &self.cancelBag)
        
    }
    
    private func presentModalsIfNeeded() {
                
//       self.tabBarNavigationService?.resetPathItems()
//        
//        let shouldShowOnboarding = !self.userDefaultsService.didCompleteOnboarding
//        let shouldShowPermissions = !self.userDefaultsService.didCompletePermission
//        
//        if shouldShowOnboarding {
//            
//            self.logger.debugMessage("Attemping to show onboarding modal")
//            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: { [weak self] in
//                
//                self?.tabBarNavigationService?
//                    .currentNavigationService()
//                    .modal(fullScreenCover: .onboarding)
//                
//                // TODO: - POTENTIALLY REMOVE THIS TOO
//                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
//                    
//                    self?.userDefaultsService
//                        .set(didCompleteOnboarding: true)
//                    
//                })
//                
//            })
//            
//        }
//        else if shouldShowPermissions {
//            
//            self.logger.debugMessage("Attemping to show permissions modal")
//            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: { [weak self] in
//                self?.shouldShowPermissionViewIfNeeded()
//            })
//            
//        }
//        else {
//            
//            self.logger.debugMessage("Attemping to show what's new modal")
//            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: { [weak self] in
//                self?.shouldShowWhatsNewIfNeeded()
//            })
//            
//        }
        
    }
    
//    private func shouldShowPermissionViewIfNeeded() {
        
//        guard !self.userDefaultsService.didCompletePermission,
//        self.permissionsService.shouldShowPermissionView else { return }
//        
//        self.logger.debugMessage("Presenting Permissions View")
//        
//        self.tabBarNavigationService?
//            .currentNavigationService()
//            .modal(sheet: .permissions)
//        
//        self.userDefaultsService
//            .set(didCompletePermission: true)
        
//    }
    
//    private func shouldShowWhatsNewIfNeeded() {
//        
//        let lastViewedVersion = self.userDefaultsService.lastViewedWhatsNewVersion
//        let whatsNewItems = Constants.WhatsNewItems.items
//        let shouldShowNewItem = whatsNewItems.filter { $0.version > SemanticVersion(lastViewedVersion ?? "") }.count > 0
//        
//        if shouldShowNewItem,
//           let latestItem = whatsNewItems.last {
//            
//            self.tabBarNavigationService?
//                .currentNavigationService()
//                .modal(sheet: .whatsNew(latestItem))
//            
//        }
//        
//    }
    
}

extension MainViewModel {
    
    func track() {
        self.analyticsService.track(screen: .main)
    }
    
}

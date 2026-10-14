//
//  MainViewModel.swift
//  LeafLaunch
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
    private let pushNotificationsService: PushNotificationServiceProtocol
    private let environmentService: EnvironmentServiceProtocol

    private(set) weak var navigationService: NavigationService?
    private var cancelBag: CancelBag!

    @Published private(set) var showShouldHomeScreen: Bool = !Constants.Capabilities.isAuthRequired
    @Published private(set) var shouldShowWelcomeScreen: Bool = Constants.Capabilities.isAuthRequired

    var readOnlyAlertService: any AlertServiceProtocol {
        return self.alertService
    }

    var isDevSettingsEnabled: Bool {
        return self.environmentService.environment != .production
    }

    // ViewModels

    @LazyInjected(\.welcomeViewModel) private(set) var welcomeViewModel: WelcomeViewModel
    @LazyInjected(\.homeViewModel) private(set) var homeViewModel: HomeViewModel

    init(alertService: AlertServiceProtocol,
         appDelegateService: AppDelegateServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         firebaseService: FirebaseServiceProtocol,
         authService: AuthServiceProtocol,
         pushNotificationsService: PushNotificationServiceProtocol,
         environmentService: EnvironmentServiceProtocol) {

        self.alertService = alertService
        self.appDelegateService = appDelegateService
        self.analyticsService = analyticsService
        self.firebaseService = firebaseService
        self.authService = authService
        self.pushNotificationsService = pushNotificationsService
        self.environmentService = environmentService

        self.logInit()
    }

    deinit {

        self.logDeinit()

    }

    func setup(navigationService: NavigationService) {
        self.navigationService = navigationService
    }

    func handleFirstAppear() {

        track()
        bindSubscribers()

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

                self?.showShouldHomeScreen = !isUserMissing || !Constants.Capabilities.isAuthRequired
                self?.shouldShowWelcomeScreen = shouldShowWelcomeScreen && Constants.Capabilities.isAuthRequired

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

}

extension MainViewModel {

    func track() {
        self.analyticsService.track(screen: .main(.root))
    }

}

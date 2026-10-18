//
//  MainViewModel.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 7/15/24.
//

import SwiftUI
import Combine

final class MainViewModel: ViewModel {

    internal let loggerName: String = "MAIN_VIEW_MODEL"
    internal let loggerEmoji: String = "🫚"

    private let alertService: AlertServiceProtocol
    private let appDelegateService: AppDelegateServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let pushNotificationsService: PushNotificationServiceProtocol
    private let environmentService: EnvironmentServiceProtocol
    private let storeSessionService: StoreSessionServiceProtocol

    let tabBarNavigationService: TabBarNavigationService
    private let makeStoreDetailsViewModel: @MainActor () -> StoreDetailsViewModel

    private(set) weak var navigationService: NavigationService?
    private var cancelBag: CancelBag!

    @Published private(set) var storeState: StoreSessionState = .loading
    @Published private(set) var storeDetailsViewModel: StoreDetailsViewModel
    private var retryTask: Task<Void, Never>?

    var storeErrorMessage: String? {
        guard self.storeSessionService.error != nil else { return nil }
        return Constants.Message.errorMessage(context: .get, "store information")
    }

    var updateURL: URL? {
        return self.storeSessionService.configuration?.updateURL
    }

    var readOnlyAlertService: any AlertServiceProtocol {
        return self.alertService
    }

    var isDevSettingsEnabled: Bool {
        return self.environmentService.environment != .production
    }

    init(alertService: AlertServiceProtocol,
         appDelegateService: AppDelegateServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         pushNotificationsService: PushNotificationServiceProtocol,
         environmentService: EnvironmentServiceProtocol,
         storeSessionService: StoreSessionServiceProtocol,
         tabBarNavigationService: TabBarNavigationService,
         makeStoreDetailsViewModel: @escaping @MainActor () -> StoreDetailsViewModel) {

        self.alertService = alertService
        self.appDelegateService = appDelegateService
        self.analyticsService = analyticsService
        self.pushNotificationsService = pushNotificationsService
        self.environmentService = environmentService
        self.storeSessionService = storeSessionService
        self.tabBarNavigationService = tabBarNavigationService
        self.makeStoreDetailsViewModel = makeStoreDetailsViewModel
        self.storeDetailsViewModel = makeStoreDetailsViewModel()

        logInit()

    }

    isolated deinit {

        self.retryTask?.cancel()
        logDeinit()

    }

    func setup(navigationService: NavigationService) {

        self.navigationService = navigationService
        globalTabBarNavigationService = self.tabBarNavigationService

    }

    func handleFirstAppear() {

        track()
        bindSubscribers()

    }

    func retryStoreLoading() {

        self.retryTask?.cancel()

        let storeSessionService = self.storeSessionService

        self.retryTask = Task { @MainActor [weak self] in

            guard !Task.isCancelled else { return }

            defer {

                if !Task.isCancelled { self?.retryTask = nil }

            }

            await storeSessionService.bootstrap()

        }

    }

    func chooseAnotherLocation() {
        self.storeSessionService.showLocations()
    }

    func handleSheetDismissal() {
        self.storeSessionService.cancelLocationSelection()
    }

    private func handleStoreNavigation(_ state: StoreSessionState) {

        guard let navigationService = self.navigationService else { return }

        switch state {
        case .locations:
            navigationService.modal(sheet: .locations)

        case .ageVerification:

            guard let locationId = self.storeSessionService.ageVerificationLocationId else { return }
            navigationService.modal(sheet: .ageVerification(locationId: locationId))

        case .store:

            guard let locationId = self.storeSessionService.locationDetails?.location.id else { return }

            if self.storeDetailsViewModel.locationId != locationId {

                self.storeDetailsViewModel = self.makeStoreDetailsViewModel()
                    .setup(locationId: locationId)

            }

            navigationService.dismissSheet()

        case .loading:
            break

        case .configurationRequired, .unavailable, .updateRequired, .failed:
            navigationService.dismissSheet()

        }

    }

    private func bindSubscribers() {

        guard self.cancelBag == nil else { return }
        self.cancelBag = CancelBag()

        self.storeSessionService.statePublisher
            .sink { [weak self] state in

                guard let self else { return }

                self.storeState = state
                self.handleStoreNavigation(state)

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

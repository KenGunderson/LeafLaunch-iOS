//
//  RootViewModel.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 7/14/24.
//

import Combine
import SwiftUI
import FactoryKit

final class RootViewModel: ViewModel {

    internal let loggerName: String = "ROOT_VIEW_MODEL"
    internal let loggerEmoji: String = "🪾"

    private let alertService: AlertServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let authService: AuthServiceProtocol
    private let pushNotificationService: PushNotificationServiceProtocol
    private(set) var userDefaultsService: UserDefaultsServiceProtocol
    private let deeplinkService: DeeplinkServiceProtocol
    private let startupService: RootStartupServiceProtocol

    let mainViewModel: MainViewModel

    @Published private(set) var launchState: LaunchScreenService.State = .loading
    @Published var shouldPresentDevSettings: Bool = false

    private(set) weak var navigationService: NavigationService?
    private var logoutTask: Task<Void, Never>?

    var observableAlertServiceWrapper: ObservableAlertServiceWrapper!

    init(analyticsService: AnalyticsServiceProtocol,
         alertService: AlertServiceProtocol,
         authService: AuthServiceProtocol,
         pushNotificationService: PushNotificationServiceProtocol,
         userDefaultsService: UserDefaultsServiceProtocol,
         deeplinkService: DeeplinkServiceProtocol,
         startupService: RootStartupServiceProtocol,
         mainViewModel: MainViewModel) {

        self.analyticsService = analyticsService
        self.alertService = alertService
        self.authService = authService
        self.pushNotificationService = pushNotificationService
        self.userDefaultsService = userDefaultsService
        self.deeplinkService = deeplinkService
        self.startupService = startupService
        self.mainViewModel = mainViewModel
        self.observableAlertServiceWrapper = ObservableAlertServiceWrapper(alertService: alertService)

        self.logInit()

    }

    isolated deinit {

        cancelTasks()
        self.logDeinit()

    }

    // MARK: - PUBLIC

    @discardableResult
    func setup(appDelegate: AppDelegate) -> Self {

        self.startupService
            .setup(appDelegate: appDelegate)

        return self

    }

    func setDeeplink(url: URL) {

        self.deeplinkService
            .handle(url: url)

    }

    func loadData() {
        bindStartupCoordinator()
    }

    func setLaunchState(_ state: LaunchScreenService.State) {

        self.startupService
            .setLaunchState(state)

    }

    func markSplashAnimationCompleted() {

        self.startupService
            .markSplashAnimationCompleted()

    }

    func trackLauchScreen() {

        self.analyticsService
            .track(screen: .launch)

    }

    func setNavigationService(_ navigationService: NavigationService) {

        self.navigationService = navigationService
        self.deeplinkService.setup(navigationService: navigationService)
        self.pushNotificationService.setup(navigationService: navigationService)

    }

    func presentHealthCheckAlert() {

        self.alertService
            .showAlert(.init(.enviornmentAlert(.init(config: Constants.HEALTH_CHECK_ENV_ALERT { [weak self] in
                self?.alertService.dismissAll()
                self?.mainViewModel.retryStoreLoading()
            }))))

    }

    func presentNoNetworkAlert() {

        self.alertService
            .showAlert(.init(.enviornmentAlert(.init(config: Constants.NO_NETWORK_ENV_ALERT { [weak self] in
                self?.alertService.dismissAll()
                self?.mainViewModel.retryStoreLoading()
            }))))

    }

    func presentForceUpdateAlert() {

        self.alertService
            .showAlert(.init(.enviornmentAlert(.init(config: Constants.FORCE_UPDATE_ENV_ALERT { [weak self] in

                guard let self else { return }
                self.alertService.dismissAll()

                if let updateURL = self.mainViewModel.updateURL {
                    UIApplication.shared.open(updateURL)
                }

            }))))

    }

    // MARK: - PRIVATE

    private func bindStartupCoordinator() {

        self.startupService.start(
            onLaunchStateChanged: { [weak self] state in
                self?.launchState = state
            },
            onAuthError: { [weak self] error in

                self?.logError(message: error.getMessageForError())
                self?.showAuthError()

            },
            onNoNetwork: { [weak self] in
                self?.presentNoNetworkAlert()
            },
            onHealthCheckResult: { [weak self] requiresForceUpdate in

                guard let self else { return }

                if requiresForceUpdate {
                    self.presentForceUpdateAlert()
                    return
                }

                self.presentHealthCheckAlert()

            }
        )

    }

    private func showAuthError() {

        self.alertService.showAlert(.init(
            .appAlert(
                .error(message: Constants.Message.authenticationErrorMessage,
                       action: { [weak self] in

                           guard let self,
                                 self.logoutTask == nil else { return }

                           let authService = self.authService

                           self.logoutTask = Task { @MainActor [weak self] in

                               guard !Task.isCancelled else { return }

                               defer {

                                   if !Task.isCancelled { self?.logoutTask = nil }

                               }

                               do {

                                   try await authService.logout()
                                   guard !Task.isCancelled else { return }

                               } catch {

                                   guard !Task.isCancelled else { return }
                                   self?.presentLogoutError()

                               }

                           }

                       }))
        ))

    }

    private func presentLogoutError() {

        self.alertService.showAlert(.init(
            .appAlert(
                .error(
                    message: Constants.Message.logoutErrorMessage,
                    action: {}
                )
            )
        ))

    }

    private func cancelTasks() {

        self.logoutTask?.cancel()

    }

}

extension RootViewModel {

    func track() {
        self.analyticsService.track(screen: .root)
    }

}

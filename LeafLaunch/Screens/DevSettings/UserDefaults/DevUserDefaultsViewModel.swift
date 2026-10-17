//
//  DevUserDefaultsViewModel.swift
//  LeafLaunch
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
    public var userDefaultsService: UserDefaultsServiceProtocol

    @Published var fullScreenCover: FullScreenCover?

    @Published var theme: AvailableTheme!
    @Published var didRateMyAppAlertShow: Bool!
    @Published var shouldHideScreenshots: Bool!

    @Published var shouldShowNoNetworkError: Bool = false
    @Published var shouldShowHealthCheckError: Bool = false
    @Published var shouldShowForceUpdateError: Bool = false

    private weak var navigationService: NavigationService?
    private var cancelBag: CancelBag!

    init(alertService: AlertServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         authService: AuthServiceProtocol,
         viewLifecycleService: ViewLifecycleServiceProtocol,
         environmentService: EnvironmentServiceProtocol,
         userDefaultsService: UserDefaultsServiceProtocol) {

        self.alertService = alertService
        self.analyticsService = analyticsService
        self.authService = authService
        self.viewLifecycleService = viewLifecycleService
        self.environmentService = environmentService
        self.userDefaultsService = userDefaultsService

        self.theme = userDefaultsService.theme
        self.didRateMyAppAlertShow = userDefaultsService.didRateMyAppAlertShow
        self.shouldHideScreenshots = userDefaultsService.shouldHideScreenshots

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

        guard self.cancelBag == nil else { return }
        self.cancelBag = CancelBag()

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
        self.didRateMyAppAlertShow = self.userDefaultsService.didRateMyAppAlertShow
        self.shouldHideScreenshots = self.userDefaultsService.shouldHideScreenshots

    }

}

extension DevUserDefaultsViewModel {

    func track() {
        self.analyticsService.track(screen: .devSettings(.userDefaults))
    }

}

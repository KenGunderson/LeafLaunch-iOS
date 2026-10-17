//
//  DevRoutesViewModel.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 7/16/24.
//

import SwiftUI
import Combine

final class DevRoutesViewModel: ViewModel {

    internal let loggerName: String = "DEV"
    internal let loggerEmoji: String = "🔧"

    private let analyticsService: AnalyticsServiceProtocol
    private let authService: AuthServiceProtocol
    private let viewLifecycleService: ViewLifecycleServiceProtocol
    private let environmentService: EnvironmentServiceProtocol

    private weak var navigationService: NavigationService?

    init(analyticsService: AnalyticsServiceProtocol,
         authService: AuthServiceProtocol,
         viewLifecycleService: ViewLifecycleServiceProtocol,
         environmentService: EnvironmentServiceProtocol) {

        self.analyticsService = analyticsService
        self.authService = authService
        self.viewLifecycleService = viewLifecycleService
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

    }

    func dismiss() {

        self.navigationService?
            .pop()

    }

    func present(modal: FullScreenCover) {

        self.navigationService?
            .modal(fullScreenCover: modal)

    }

}

extension DevRoutesViewModel {

    func track() {
        self.analyticsService.track(screen: .devSettings(.routes))
    }

}

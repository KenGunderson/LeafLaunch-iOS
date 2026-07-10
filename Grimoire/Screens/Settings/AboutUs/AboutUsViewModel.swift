//
//  AboutUsViewModel.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 9/12/25.
//

import SwiftUI
import Combine

final class AboutUsViewModel: ViewModel {

    internal let loggerName: String = "ABOUT_US_VIEW_MODEL"
    internal let loggerEmoji: String = "⚙️"

    private let apiService: APIServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let authService: AuthServiceProtocol
    private let alertService: AlertServiceProtocol
    private let viewLifecycleService: ViewLifecycleServiceProtocol
    private let environmentService: EnvironmentServiceProtocol

    private weak var navigationService: NavigationService?

    private var cancelBag: CancelBag!

    init(apiService: APIServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         authService: AuthServiceProtocol,
         alertService: AlertServiceProtocol,
         viewLifecycleService: ViewLifecycleServiceProtocol,
         environmentService: EnvironmentServiceProtocol) {

        self.apiService = apiService
        self.analyticsService = analyticsService
        self.authService = authService
        self.alertService = alertService
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
        bindSubscribers()

    }

    func dismiss() {

        self.navigationService?
            .pop()

    }

    func tagLine() -> String {
        return "Built for the hands that make others glow."
    }

    private func bindSubscribers() {
        self.cancelBag = CancelBag()
    }

}

extension AboutUsViewModel {

    func track() {
        self.analyticsService.track(screen: .settings(.aboutUs))
    }

}

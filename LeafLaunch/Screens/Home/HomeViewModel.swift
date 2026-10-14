//
//  HomeViewModel.swift
//  LeafLaunch
//

import Foundation

final class HomeViewModel: ViewModel {

    internal let loggerName: String = "HOME_VIEW_MODEL"
    internal let loggerEmoji: String = "🏡"

    private let analyticsService: AnalyticsServiceProtocol
    private weak var navigationService: NavigationService?

    init(analyticsService: AnalyticsServiceProtocol) {
        self.analyticsService = analyticsService

        self.logInit()

    }

    deinit {
        self.logDeinit()
    }

    @discardableResult
    func setup(navigationService: NavigationService) -> Self {

        self.navigationService = navigationService
        return self

    }

    func handleFirstAppear() {
        track()
    }

    func presentSettings() {
        self.navigationService?.modal(fullScreenCover: .settings)
    }

}

extension HomeViewModel {

    func track() {
        self.analyticsService.track(screen: .home)
    }

}

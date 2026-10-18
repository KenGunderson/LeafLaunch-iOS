//
//  LegalDetailsViewModel.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 1/23/25.
//

import SwiftUI
import Combine

final class LegalDetailsViewModel: ViewModel {

    internal let loggerName: String = "LEGAL_DETAILS_VIEW_MODEL"
    internal let loggerEmoji: String = "⚙️"


    private let apiService: APIServiceProtocol
    private let authService: AuthServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let alertService: AlertServiceProtocol
    private let viewLifecycleService: ViewLifecycleServiceProtocol
    private let environmentService: EnvironmentServiceProtocol

    private(set) var context: Context!
    private weak var navigationService: NavigationService?


    @Published private(set) var legalItems: [LegalItem] = []

    init(apiService: APIServiceProtocol,
         authService: AuthServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         alertService: AlertServiceProtocol,
         viewLifecycleService: ViewLifecycleServiceProtocol,
         environmentService: EnvironmentServiceProtocol) {

        self.apiService = apiService
        self.analyticsService = analyticsService
        self.alertService = alertService
        self.authService = authService
        self.viewLifecycleService = viewLifecycleService
        self.environmentService = environmentService

        logInit()

    }

    deinit {
        logDeinit()
    }

    @discardableResult
    func setup(context: Context) -> Self {

        self.context = context
        return self

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

}

extension LegalDetailsViewModel {

    func track() {
        self.analyticsService.track(screen: .settings(.legal(context: self.context.dataName)))
    }

}

//
//  OnboardingViewModel.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 7/19/24.
//

import Combine
import SwiftUI

final class OnboardingViewModel: ViewModel {

    internal let loggerName: String = "ONBOARDING_VIEW_MODEL"
    internal let loggerEmoji: String = "🛹"

    private weak var navigationService: NavigationService?

    private let analyticsService: AnalyticsServiceProtocol
    private(set) var permissionService: PermissionsServiceProtocol
    private let alertService: AlertServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol

    @Published var currentPageIndex: Int = 0

    var pages: [OnboardingPage] = []

    @Published var currentPage: OnboardingPage!

    @Published private(set) var didAcknowledgePermissions: Bool = false

    var progress: CGFloat {
        return CGFloat(Double(self.currentPageIndex + 1) / Double(self.pages.count))
    }

    var formattedProgress: String {
        return "\(self.currentPageIndex + 1)/\(self.pages.count)"
    }

    var formattedProgressPercentage: String {
        return formatProgress()
    }

    var isFirstPage: Bool {
        self.currentPageIndex == 0
    }

    var isLastPage: Bool {
        self.currentPageIndex == self.pages.count - 1
    }

    var canGoBack: Bool {
        return self.currentPageIndex > 0
    }

    var featurePages: [OnboardingPage] {
        return self.pages.filter { isFeaturePage($0) }
    }

    var isCurrentPageComplete: Bool {
        return self.currentPage == .permission ? self.didAcknowledgePermissions : true
    }

    private var cancelBag: CancelBag!

    init(analyticsService: AnalyticsServiceProtocol,
         permissionService: PermissionsServiceProtocol,
         alertService: AlertServiceProtocol,
         userDefaultsService: UserDefaultsServiceProtocol) {

        self.analyticsService = analyticsService
        self.userDefaultsService = userDefaultsService
        self.alertService = alertService
        self.permissionService = permissionService

        self.logInit()
        self.didAcknowledgePermissions = !self.permissionService.shouldShowPermissionView

    }

    deinit {
        self.logDeinit()
    }

    @discardableResult
    func setup(pages: [OnboardingPage]) -> Self {

        self.pages = pages
        self.currentPage = pages.first ?? .businessSetup
        self.currentPageIndex = self.pages.firstIndex(of: self.currentPage) ?? 0

        return self

    }

    func setup(navigationService: NavigationService) {
        self.navigationService = navigationService
    }

    func handleFirstAppear() {

        track()
        bindSubscribers()

    }

    func nextPage() {

        if self.pages.indices.contains(self.currentPageIndex + 1) {

            let nextPage = self.pages[self.currentPageIndex + 1]
            self.currentPageIndex += 1
            self.currentPage = nextPage

            switch nextPage {
            case .businessSetup,
                    .locationControl,
                    .photos,
                    .beforeAndAfter,
                    .documentation:

                return

            case .permission: self.navigationService?.push(.onboarding(.permission))
            }

        }

    }

    func previousPage() {

        guard self.canGoBack else { return }
        guard let currentPage else { return }

        if isFeaturePage(currentPage) {

            let previousIndex = self.currentPageIndex - 1

            guard self.pages.indices.contains(previousIndex) else { return }

            self.currentPageIndex = previousIndex
            self.currentPage = self.pages[previousIndex]
            return

        }

        self.navigationService?.pop()

    }

    func updateCurrentFeaturePage(_ page: OnboardingPage) {

        guard self.featurePages.contains(page) else { return }

        self.currentPage = page
        self.currentPageIndex = self.pages.firstIndex(of: page) ?? 0

    }

    func findNavigationRouteIndex(routes: [Route]) {

        if routes.isEmpty {

            if let currentPage, isFeaturePage(currentPage) {
                return
            }

            let fallbackPage = self.featurePages.last ?? self.pages.first ?? .businessSetup
            self.currentPage = fallbackPage
            self.currentPageIndex = self.pages.firstIndex(of: fallbackPage) ?? 0
            return

        }

        guard let latestRoute = routes.last else { return }

        switch latestRoute {
        case .onboarding(let route):

            switch route {
            case .businessSetup:

                self.currentPage = .businessSetup
                self.currentPageIndex = self.pages.firstIndex(of: .businessSetup) ?? 0

            case .locationControl:

                self.currentPage = .locationControl
                self.currentPageIndex = self.pages.firstIndex(of: .locationControl) ?? 0

            case .photos:

                self.currentPage = .photos
                self.currentPageIndex = self.pages.firstIndex(of: .photos) ?? 0

            case .beforeAndAfter:

                self.currentPage = .beforeAndAfter
                self.currentPageIndex = self.pages.firstIndex(of: .beforeAndAfter) ?? 0

            case .documentation:

                self.currentPage = .documentation
                self.currentPageIndex = self.pages.firstIndex(of: .documentation) ?? 0

            case .permission:

                self.currentPage = .permission
                self.currentPageIndex = self.pages.firstIndex(of: .permission) ?? 0
            }

        default: return
        }

    }

    func finish() {

        self.logger.debug("Finished Onboarding")

        self.userDefaultsService
            .set(didCompleteOnboarding: true)

    }

    private func formatProgress() -> String {

        let updatedProgress = CGFloat(Double(self.currentPageIndex + 1) / Double(self.pages.count))
        let formatter = FloatingPointFormatStyle<Double>.Percent.percent
        let formattedProgress = formatter.precision(.fractionLength(0))
        return updatedProgress.formatted(formattedProgress)

    }

    private func bindSubscribers() {

        self.cancelBag = CancelBag()

        self.permissionService
            .shouldShowPermissionViewPublisher
            .sink { [weak self] shouldShowPermissionView in

                self?.didAcknowledgePermissions = !shouldShowPermissionView

            }
            .store(in: &self.cancelBag)

    }

    private func isFeaturePage(_ page: OnboardingPage) -> Bool {

        switch page {
        case .businessSetup,
                .locationControl,
                .photos,
                .beforeAndAfter,
                .documentation:

            return true

        case .permission:
            return false
        }

    }

}

extension OnboardingViewModel {

    func track() {
        self.analyticsService.track(screen: .onboarding(.onboarding))
    }

}

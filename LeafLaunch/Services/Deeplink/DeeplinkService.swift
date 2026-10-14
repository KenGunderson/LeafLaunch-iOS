//
//  DeeplinkService.swift
//  LeafLaunch
//

import Foundation

final class DeeplinkService: DeeplinkServiceProtocol {

    internal let loggerName: String = "DEEPLINK_SERVICE"
    internal let loggerEmoji: String = "🔗"

    private weak var navigationService: NavigationService?
    private let lifecycleService: ViewLifecycleServiceProtocol

    private var pendingURL: URL?
    private var lastProcessedURLString: String?
    private var lastProcessedAt: Date?
    private let duplicateSuppressionInterval: TimeInterval = 1

    init(lifecycleService: ViewLifecycleServiceProtocol) {
        self.lifecycleService = lifecycleService
        self.logInit()

    }

    deinit {
        self.logDeinit()
    }

    func setup(navigationService: NavigationService) {

        self.navigationService = navigationService

        if let pendingURL = self.pendingURL {

            self.pendingURL = nil
            handle(url: pendingURL)

        }

    }

    func handle(url: URL) {

        guard let navigationService = self.navigationService else {

            self.pendingURL = url
            self.log(message: "Queue URL until navigation is ready: \(url)")
            return

        }

        let now = Date()
        let urlString = url.absoluteString

        if self.lastProcessedURLString == urlString,
           let lastProcessedAt = self.lastProcessedAt,
           now.timeIntervalSince(lastProcessedAt) < self.duplicateSuppressionInterval {

            self.log(message: "Ignore duplicate URL \(url)")
            return

        }

        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              components.host != nil else { return }

        let route = components.path.split(separator: "/").first.map(String.init) ?? components.host

        switch route {
        case "home":
            navigateHome(using: navigationService)
        case "settings":
            navigationService.modal(fullScreenCover: .settings)
        case "tab":

            let tabValue = components.queryItems?.first(where: { $0.name == "tab" })?.value
            guard let tabValue, let tab = Tab(rawValue: tabValue) else { return }

            // Legacy tab links stay explicit while tabs are reserved for a future child flow.
            guard tab == .tab1 else {

                self.log(message: "Tab link reserved for a future child flow: \(tab.rawValue)")
                return

            }

            navigateHome(using: navigationService)

        default:
            return
        }

        self.lastProcessedURLString = urlString
        self.lastProcessedAt = now
        self.log(message: "Handle URL \(url)")

    }

    private func navigateHome(using navigationService: NavigationService) {

        navigationService.dismissFullScreenCover()
        navigationService.popToRoot()

    }

}

//
//  SettingsViewModel.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 6/21/25.
//

import Foundation
import UIKit

final class SettingsViewModel: ViewModel {

    internal let loggerName: String = "SETTINGS_VIEW_MODEL"
    internal let loggerEmoji: String = "⚙️"

    private let authService: AuthServiceProtocol
    private let apiService: APIServiceProtocol
    private let alertService: AlertServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let environmentService: EnvironmentServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol
    private let viewLifecycleService: ViewLifecycleServiceProtocol

    private weak var navigationService: NavigationService?
    private var logoutTask: Task<Void, Never>?

    @Published private(set) var shouldDismiss: Bool = false

    @Published var shouldShowRateAppAlert: Bool = false
    @Published var shouldShowMailComposer: Bool = false

    @MainActor
    var appVersion: String {

        let env = self.environmentService.environment?.description ?? ""
        return "\(env) - \(UIApplication.version)"

    }

    var emailData: EmailComposerData {

        return .init(
            subject: "Customer Support",
            recipients: [Constants.Legal.supportEmail],
            body: "",
            isHTML: false,
            attachments: [])

    }

    init(authService: AuthServiceProtocol,
         apiService: APIServiceProtocol,
         alertService: AlertServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         environmentService: EnvironmentServiceProtocol,
         userDefaultsService: UserDefaultsServiceProtocol,
         viewLifecycleService: ViewLifecycleServiceProtocol) {

        self.authService = authService
        self.apiService = apiService
        self.alertService = alertService
        self.analyticsService = analyticsService
        self.environmentService = environmentService
        self.userDefaultsService = userDefaultsService
        self.viewLifecycleService = viewLifecycleService

        self.logInit()

    }

    isolated deinit {

        cancelTasks()
        self.logDeinit()

    }

    @MainActor
    func selectSetting(_ setting: Route.SettingRoute) {

        switch setting {
        case .logout:

            presentLogoutAlert()

        case .contactSupport:

            self.shouldShowMailComposer = true

        case .rateApp:

            reviewApp()

        default:

            self.navigationService?.push(.settings(setting))
        }

    }

    func setup(navigationService: NavigationService){
        self.navigationService = navigationService
    }

    func handleFirstAppear() {

        track()

    }

    private func reviewApp() {

        self.shouldShowRateAppAlert = true
        self.userDefaultsService.set(didRateMyAppAlertShow: true)

    }

    private func logout() {

        guard self.logoutTask == nil else { return }

        let authService = self.authService
        self.logoutTask = Task { @MainActor [weak self] in

            guard !Task.isCancelled else { return }

            defer {

                if !Task.isCancelled { self?.logoutTask = nil }

            }

            do {

                try await Task.sleep(for: .seconds(0.3))
                guard !Task.isCancelled else { return }

                try await authService.logout()
                guard !Task.isCancelled else { return }

                self?.shouldDismiss = true

            } catch {

                guard !Task.isCancelled else { return }
                self?.presentLogoutError()

            }

        }

    }

    private func presentLogoutAlert() {

        self.alertService
            .showAlert(.init(.appAlert(.init(
                title: "Logout?",
                message: "Are you sure you want to logout?",
                primaryButtonTitle: "Yes",
                primaryButtonAction: { [weak self] in
                    self?.logout()
                },
                primaryButtonBackgroundColor: .foreground(.primary),
                primaryButtonTextColor: .text(.button),
                secondaryButtonTitle: "No",
                secondaryButtonAction: {},
                secondaryButtonBackgroundColor: .background(.quaternary),
                secondaryButtonTextColor: .text(.title)
            ))))

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

extension SettingsViewModel {

    func track() {
        self.analyticsService.track(screen: .settings(.settings))
    }

}

//
//  SettingsViewModel.swift
//  GlowPro
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
    private var cancelBag: CancelBag!
    private var logoutTask: Task<Void, Never>?

    @Published private(set) var shouldDismiss: Bool = false

    @Published private(set)var isLoading: Bool = true
    @Published private(set) var isFirstLoad: Bool = true

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

        case .updatePermissions:

            self.alertService
                .showAlert(.init(.appAlert(.success(message: "Clicked the correct button", action: {
                    print("Test")
                }))))

            ToastManager
                .shared
                .present(toastItem: .init(title: "Some Toasy"))

//            if let url = URL(string: UIApplication.openSettingsURLString) {
//                UIApplication.shared.open(url)
//            }

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
        bindSubscribers()

    }

    func loadData(showHud: Bool = true) {

        self.isLoading = false
        self.isFirstLoad = false

    }

    private func bindSubscribers() {
        self.cancelBag = CancelBag()
    }

    private func reviewApp() {

        self.shouldShowRateAppAlert = true
        self.userDefaultsService.set(didRateMyAppAlertShow: true)

    }

    private func logout() {

        self.logoutTask?.cancel()

        let authService = self.authService
        self.logoutTask = Task { [weak self] in

            do {
                try await Task.sleep(for: .seconds(0.3))
            }
            catch {
                return
            }
            guard !Task.isCancelled else { return }

            self?.shouldDismiss = true

            do {
                try await Task.sleep(for: .seconds(0.3))
            }
            catch {
                return
            }
            guard !Task.isCancelled else { return }

            do {
                try await authService.logout()
            }
            catch {
                guard !Task.isCancelled else { return }
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
                primaryButtonBackgroundColor: Style.shared.accent,
                primaryButtonTextColor: Style.shared.textColor(.button),
                secondaryButtonTitle: "No",
                secondaryButtonAction: {},
                secondaryButtonBackgroundColor: Style.shared.background(.quaternary),
                secondaryButtonTextColor: Style.shared.textColor(.title)
            ))))

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

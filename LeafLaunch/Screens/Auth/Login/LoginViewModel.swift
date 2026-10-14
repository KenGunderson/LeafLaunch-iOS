//
//  LoginViewModel.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 5/16/25.
//

import SwiftUI
import Combine
import AuthenticationServices

final class LoginViewModel: ViewModel {

    internal let loggerName: String = "LOGIN_VIEW_MODEL"
    internal let loggerEmoji: String = "👤"

    private let alertService: AlertServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let authService: AuthServiceProtocol
    private let viewLifecycleService: ViewLifecycleServiceProtocol
    private let environmentService: EnvironmentServiceProtocol

    private weak var navigationService: NavigationService?
    private var cancelBag: CancelBag!
    private var appleAuthorizationTask: Task<Void, Never>?
    private var forgotPasswordTask: Task<Void, Never>?
    private var loginTask: Task<Void, Never>?

    @Published var email: String = ""
    @Published var password: String = ""

    @Published private(set) var currentNonce: String?

    @Published var shouldPresentForgotPassword = false
    @Published private(set) var isLoading: Bool = false

    var isButtonEnabled: Bool {

        return (
            !self.isLoading &&
            self.email.trimmed().count > 3 &&
            self.password.count >= 6
        )

    }

    init(alertService: AlertServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         authService: AuthServiceProtocol,
         viewLifecycleService: ViewLifecycleServiceProtocol,
         environmentService: EnvironmentServiceProtocol) {

        self.alertService = alertService
        self.analyticsService = analyticsService
        self.authService = authService
        self.viewLifecycleService = viewLifecycleService
        self.environmentService = environmentService

        logInit()

    }

    isolated deinit {

        cancelTasks()
        logDeinit()

    }

    func set(nonce: String) {
        self.currentNonce = nonce
    }

    func dismiss() {
        self.navigationService?.pop()
    }

    func handleForgotPassword() {

        guard !self.isLoading else { return }

        self.analyticsService.track(.auth(.forgotPasswordIntent))
        self.shouldPresentForgotPassword = true

    }

    func setup(navigationService: NavigationService) {
        self.navigationService = navigationService
    }

    func handleFirstAppear() {

        track()
        bindSubscribers()

    }

    @MainActor
    func handleAppleAuthoriziation(result: Result<ASAuthorization, any Error>) {

        guard !self.isLoading else { return }

        switch result {
        case .success(let authorization):

            self.appleAuthorizationTask?.cancel()
            self.isLoading = true

            let alertService = self.alertService
            let analyticsService = self.analyticsService
            let authService = self.authService
            let currentNonce = self.currentNonce

            self.appleAuthorizationTask = Task { @MainActor [weak self] in

                guard !Task.isCancelled else { return }

                let loadingIndicator = RuneAlert(.simpleLoadingIndicator)
                alertService.showAlert(loadingIndicator)

                defer {

                    alertService.dismissAlert(loadingIndicator)
                    self?.isLoading = false
                    self?.appleAuthorizationTask = nil

                }

                analyticsService
                    .track(.auth(.appleLoginIntent))

                do {

                    try await authService.handleAppleSignupOrLogin(
                        currentNonce: currentNonce,
                        authorization: authorization,
                        isLogin: true
                    )

                    guard !Task.isCancelled else { return }
                    self?.dismiss()

                }
                catch {

                    guard !Task.isCancelled else { return }
                    self?.presentAuthError(error)

                }

            }

        case .failure(let error):
            presentAuthError(error)
        }

    }

    @MainActor
    func handleForgetPassword(email: String) {

        guard !self.isLoading else { return }

        self.forgotPasswordTask?.cancel()
        self.isLoading = true
        self.shouldPresentForgotPassword = false

        let alertService = self.alertService
        let authService = self.authService
        let analyticsService = self.analyticsService
        let email = email.trimmed()

        self.forgotPasswordTask = Task { @MainActor [weak self] in

            guard !Task.isCancelled else { return }

            let loadingIndicator = RuneAlert(.simpleLoadingIndicator)
            alertService.showAlert(loadingIndicator)

            defer {

                alertService.dismissAlert(loadingIndicator)
                self?.isLoading = false
                self?.forgotPasswordTask = nil

            }

            do {

                try await authService.resetPassword(email: email)
                guard !Task.isCancelled else { return }

                analyticsService
                    .track(.auth(.forgotPassword(email: email)))

                alertService.showAlert(.init(
                    .appAlert(
                        .success(
                            message: "If an account exists for that email, password reset instructions are on the way.",
                            action: {}
                        )
                    )
                ))

            }
            catch {

                guard !Task.isCancelled else { return }
                self?.presentAuthError(error)

            }

        }

    }

    @MainActor
    func handleLogin() {

        guard self.isButtonEnabled else { return }

        self.analyticsService
            .track(.auth(.loginIntent))

        self.loginTask?.cancel()
        self.isLoading = true

        let alertService = self.alertService
        let authService = self.authService
        let email = self.email.trimmed()
        let password = self.password

        self.loginTask = Task { @MainActor [weak self] in

            guard !Task.isCancelled else { return }

            let loadingIndicator = RuneAlert(.simpleLoadingIndicator)
            alertService.showAlert(loadingIndicator)

            defer {

                alertService.dismissAlert(loadingIndicator)
                self?.isLoading = false
                self?.loginTask = nil

            }

            do {

                try await authService.login(
                    email: email,
                    password: password
                )

                guard !Task.isCancelled else { return }
                self?.dismiss()

            }
            catch {

                guard !Task.isCancelled else { return }
                self?.presentAuthError(error)

            }

        }

    }

    private func bindSubscribers() {

        guard self.cancelBag == nil else { return }
        self.cancelBag = CancelBag()

    }

    private func presentAuthError(_ error: Error) {

        guard !(error is CancellationError) else { return }
        if let authorizationError = error as? ASAuthorizationError,
           authorizationError.code == .canceled { return }

        self.alertService.showAlert(.init(
            .appAlert(
                .error(
                    message: error.getMessageForError(),
                    action: {}
                )
            )
        ))

    }

    private func cancelTasks() {

        self.appleAuthorizationTask?.cancel()
        self.forgotPasswordTask?.cancel()
        self.loginTask?.cancel()

    }

}

extension LoginViewModel {

    func track() {
        self.analyticsService.track(screen: .auth(.login))
    }

}

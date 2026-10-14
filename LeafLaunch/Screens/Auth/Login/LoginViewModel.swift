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
    @Published var error: Error?

    var isButtonEnabled: Bool {

        return (
            self.email.count > 3 &&
            self.password.count >= 6
        )

    }

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

    isolated deinit {

        cancelTasks()
        self.logDeinit()

    }

    func set(nonce: String) {
        self.currentNonce = nonce
    }

    func dismiss() {
        self.navigationService?.pop()
    }

    func handleForgotPassword() {

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

        switch result {
        case .success(let authorization):

            self.appleAuthorizationTask?.cancel()

            let analyticsService = self.analyticsService
            let authService = self.authService
            let currentNonce = self.currentNonce

            self.appleAuthorizationTask = Task { [weak self] in

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
                catch(let error) {

                    guard !Task.isCancelled else { return }
                    self?.error = error

                }

            }

        case .failure(let error): self.error = error
        }

    }

    @MainActor
    func handleForgetPassword(email: String) {

        self.forgotPasswordTask?.cancel()

        let authService = self.authService
        let analyticsService = self.analyticsService

        self.forgotPasswordTask = Task { [weak self] in

            do {

                try await authService.resetPassword(email: email)

                analyticsService
                    .track(.auth(.forgotPassword(email: email)))

            }
            catch(let error) {

                guard !Task.isCancelled else { return }
                self?.error = error

            }

        }

    }

    @MainActor
    func handleLogin() {

        self.analyticsService
            .track(.auth(.loginIntent))

        self.loginTask?.cancel()

        let authService = self.authService
        let email = self.email.trimmed()
        let password = self.password.trimmed()

        self.loginTask = Task { [weak self] in

            do {

                try await authService.login(
                    email: email,
                    password: password
                )

                guard !Task.isCancelled else { return }
                self?.dismiss()

            }
            catch(let error) {

                guard !Task.isCancelled else { return }
                self?.error = error

            }

        }

    }

    private func bindSubscribers() {
        self.cancelBag = CancelBag()
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

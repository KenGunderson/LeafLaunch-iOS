//
//  SignUpViewModel.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 5/16/25.
//

import SwiftUI
import Combine
import AuthenticationServices

final class SignUpViewModel: ViewModel {

    internal let loggerName: String = "SIGN_UP_VIEW_MODEL"
    internal let loggerEmoji: String = "👤"

    private let alertService: AlertServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let authService: AuthServiceProtocol
    private let viewLifecycleService: ViewLifecycleServiceProtocol
    private let environmentService: EnvironmentServiceProtocol

    private weak var navigationService: NavigationService?
    private var cancelBag: CancelBag!
    private var appleAuthorizationTask: Task<Void, Never>?
    private var signUpTask: Task<Void, Never>?

    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var agreedToTerms: Bool = false

    @Published private var currentNonce: String?
    @Published private(set) var isLoading: Bool = false

    var isButtonEnabled: Bool {

        return (
            !self.isLoading &&
            self.email.trimmed().count > 3 &&
            self.password.count >= 6 &&
            self.firstName.trimmed().count >= 2 &&
            self.lastName.trimmed().count >= 2
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
                    .track(.auth(.appleSignupIntent))

                do {

                    try await authService.handleAppleSignupOrLogin(
                        currentNonce: currentNonce,
                        authorization: authorization,
                        isLogin: false
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
    func handleSignUp() {

        guard self.isButtonEnabled else { return }

        self.analyticsService
            .track(.auth(.signupIntent))

        self.signUpTask?.cancel()
        self.isLoading = true

        let alertService = self.alertService
        let authService = self.authService
        let firstName = self.firstName.capitalized.trimmed()
        let lastName = self.lastName.capitalized.trimmed()
        let email = self.email.trimmed()
        let password = self.password

        self.signUpTask = Task { @MainActor [weak self] in

            guard !Task.isCancelled else { return }

            let loadingIndicator = RuneAlert(.simpleLoadingIndicator)
            alertService.showAlert(loadingIndicator)

            defer {

                alertService.dismissAlert(loadingIndicator)
                self?.isLoading = false
                self?.signUpTask = nil

            }

            do {

                try await authService.signup(
                    firstName: firstName,
                    lastName: lastName,
                    email: email,
                    password: password
                )

                guard !Task.isCancelled else { return }

                self?.navigationService?
                    .popToRoot()

            }
            catch {

                guard !Task.isCancelled else { return }
                self?.presentAuthError(error)

            }

        }

    }

    func dismiss() {
        self.navigationService?.pop()
    }

    func setup(navigationService: NavigationService) {
        self.navigationService = navigationService
    }

    func handleFirstAppear() {

        track()
        bindSubscribers()

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
        self.signUpTask?.cancel()

    }

}

extension SignUpViewModel {

    func track() {
        self.analyticsService.track(screen: .auth(.signUp))
    }

}

//
//  DevImpersonateViewModel.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 11/4/24.
//

import SwiftUI

final class DevImpersonateViewModel: ViewModel {

    internal let loggerName: String = "DEV"
    internal let loggerEmoji: String = "🔧"

    private(set) var analyticsService: AnalyticsServiceProtocol
    private let impersonateService: ImpersonateServiceProtocol
    private let alertService: AlertServiceProtocol
    private let viewLifecycleService: ViewLifecycleServiceProtocol
    private let environmentService: EnvironmentServiceProtocol

    private weak var navigationService: NavigationService?
    private var cancelBag: CancelBag!
    private var impersonationTask: Task<Void, Never>?

    @Published var userToImpersonateEmail: String = ""
    @Published var isImpersonating: Bool?

    init(analyticsService: AnalyticsServiceProtocol,
         impersonateService: ImpersonateServiceProtocol,
         viewLifecycleService: ViewLifecycleServiceProtocol,
         alertService: AlertServiceProtocol,
         environmentService: EnvironmentServiceProtocol) {

        self.analyticsService = analyticsService
        self.impersonateService = impersonateService
        self.alertService = alertService
        self.viewLifecycleService = viewLifecycleService
        self.environmentService = environmentService

        self.logInit()

    }

    isolated deinit {
        
        cancelTasks()
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

    func impersonateOrRevert() {

        guard let isImpersonating else { return }

        if !isImpersonating {
            impersonate()
        } else {
            revert()
        }

    }

    private func impersonate() {

        guard !self.userToImpersonateEmail.isEmpty else { return }

        let loadingAlert = RuneAlert(.loadingIndicator(
            .init(loadStyle: .progressView(title: "Impersonating", tintColor: Style.shared.accent))
        ))

        self.impersonationTask?.cancel()

        let alertService = self.alertService
        let impersonateService = self.impersonateService

        self.impersonationTask = Task { [weak self, userToImpersonateEmail] in

            alertService
                .showAlert(loadingAlert)

            defer {

                alertService
                    .dismissAlert(loadingAlert)

            }

            do {

                try await impersonateService
                    .impersonateUser(email: userToImpersonateEmail)

            }
            catch {
                guard !Task.isCancelled else { return }
                self?.presentError(error)
            }

        }

    }

    private func revert() {

        let loadingAlert = RuneAlert(.loadingIndicator(
            .init(loadStyle: .progressView(title: "Impersonating", tintColor: Style.shared.accent))
        ))

        self.impersonationTask?.cancel()

        let alertService = self.alertService
        let impersonateService = self.impersonateService

        self.impersonationTask = Task { [weak self] in

            alertService
                .showAlert(loadingAlert)

            defer {

                alertService
                    .dismissAlert(loadingAlert)

            }

            do {
                try await impersonateService.revert()
            }
            catch {
                guard !Task.isCancelled else { return }
                self?.presentError(error)
            }

        }

    }

    func bindSubscribers() {

        self.cancelBag = CancelBag()

        self.impersonateService
            .impersonatedUserPublisher
            .receiveOnMain()
            .sink { [weak self] impersonatedUser in

                self?.isImpersonating = (impersonatedUser != nil)
                self?.userToImpersonateEmail = impersonatedUser?.email ?? ""

            }
            .store(in: &self.cancelBag)

    }

    private func presentError(_ error: Error) {

        self.alertService
            .showAlert(
                .init(
                    .appAlert(
                        .error(
                            message: error.getMessageForError(),
                            action: {}
                        )
                    )
                )
            )

    }

    private func cancelTasks() {
        self.impersonationTask?.cancel()
    }

}

extension DevImpersonateViewModel {

    func track() {
        self.analyticsService.track(screen: .devSettings(.impersonate))
    }

}

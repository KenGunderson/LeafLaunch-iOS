//
//  ProfileViewModel.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 10/28/25.
//

import SwiftUI
import Combine

final class ProfileViewModel: ViewModel {
    
    internal let loggerName: String = "PROFILE_VIEW_MODEL"
    internal let loggerEmoji: String = "⚙️"
    
    private let apiService: APIServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let authService: AuthServiceProtocol
    private let alertService: AlertServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol
    private let viewLifecycleService: ViewLifecycleServiceProtocol
    private let environmentService: EnvironmentServiceProtocol
    private weak var navigationService: NavigationService?
    
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var email: String = ""
    @Published private(set) var isLoading: Bool = true
    @Published private(set) var isUpdating: Bool = false
    
    var isSubmitButtonEnabled: Bool {
        return isSaveButtonEnabled()
    }
    
    private(set) var businessId: String?
    private var cancelBag: CancelBag!
    private var loadDataTask: Task<Void, Never>?
    private var updateTask: Task<Void, Never>?
    private var loadRequestId: UUID?
    private var loadedUserId: String?
        
    init(apiService: APIServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         authService: AuthServiceProtocol,
         alertService: AlertServiceProtocol,
         userDefaultsService: UserDefaultsServiceProtocol,
         viewLifecycleService: ViewLifecycleServiceProtocol,
         environmentService: EnvironmentServiceProtocol) {
        
        self.apiService = apiService
        self.analyticsService = analyticsService
        self.authService = authService
        self.alertService = alertService
        self.userDefaultsService = userDefaultsService
        self.viewLifecycleService = viewLifecycleService
        self.environmentService = environmentService
        
        logInit()
        
    }
    
    isolated deinit {
        
        cancelTasks()
        logDeinit()
        
    }
    
    func setup(navigationService: NavigationService) {
        self.navigationService = navigationService
    }

    func handleFirstAppear() {
        
        track()
        bindSubscribers()
        
    }
    
    func loadData(showHud: Bool = true) {

        guard !self.isUpdating else { return }

        self.loadDataTask?.cancel()
        self.loadDataTask = nil
        self.loadRequestId = nil

        guard let userId = self.authService.currentUser?.id else {

            self.loadedUserId = nil
            self.firstName = ""
            self.lastName = ""
            self.email = ""
            self.isLoading = false
            return

        }

        if self.loadedUserId != userId {

            self.loadedUserId = nil
            self.firstName = ""
            self.lastName = ""
            self.email = ""

        }

        self.isLoading = true

        let requestId = UUID()
        let alertService = self.alertService
        let authService = self.authService

        self.loadRequestId = requestId

        self.loadDataTask = Task { @MainActor [weak self] in

            let loadingIndicator = showHud ? RuneAlert(.simpleLoadingIndicator) : nil

            if let loadingIndicator {
                alertService.showAlert(loadingIndicator)
            }

            defer {

                if let loadingIndicator {
                    alertService.dismissAlert(loadingIndicator)
                }

                if self?.loadRequestId == requestId {

                    self?.loadRequestId = nil
                    self?.loadDataTask = nil
                    self?.isLoading = false

                }

            }

            guard !Task.isCancelled,
                  self?.loadRequestId == requestId,
                  authService.currentUser?.id == userId else { return }

            do {

                try await authService.reloadUser()
                guard !Task.isCancelled,
                      self?.loadRequestId == requestId,
                      let user = authService.currentUser,
                      user.id == userId else { return }

                self?.populateProfile(user: user)

            }
            catch {

                guard !Task.isCancelled,
                      self?.loadRequestId == requestId,
                      authService.currentUser?.id == userId else { return }

                self?.presentProfileError(context: .get)

            }

        }

    }
    
    func dismiss() {
        
        self.navigationService?
            .pop()
        
    }
    
    func update() {

        guard self.isSubmitButtonEnabled,
              let userId = self.authService.currentUser?.id,
              self.loadedUserId == userId else { return }

        self.updateTask?.cancel()
        self.isUpdating = true

        let alertService = self.alertService
        let apiService = self.apiService
        let authService = self.authService
        let displayName = self.displayName

        self.updateTask = Task { @MainActor [weak self] in

            let loadingIndicator = RuneAlert(.simpleLoadingIndicator)
            alertService.showAlert(loadingIndicator)

            defer {

                alertService.dismissAlert(loadingIndicator)
                self?.updateTask = nil
                self?.isUpdating = false

            }

            guard !Task.isCancelled, authService.currentUser?.id == userId else { return }

            do {

                let account = try await apiService.updateCustomerAccount(displayName: displayName)
                guard !Task.isCancelled, authService.currentUser?.id == userId else { return }
                guard account.id == userId else { throw APIError.decodingError }

                try await authService.reloadUser()
                guard !Task.isCancelled,
                      let user = authService.currentUser,
                      user.id == userId else { return }

                self?.populateProfile(user: user)

                alertService.showAlert(.init(
                    .appAlert(
                        .success(
                            message: "Profile updated successfully.",
                            action: { [weak self] in
                                self?.navigationService?.popWithDelay()
                            }
                        )
                    )
                ))

            }
            catch {

                guard !Task.isCancelled, authService.currentUser?.id == userId else { return }
                self?.presentProfileError(context: .update)

            }

        }

    }
    
    private func isSaveButtonEnabled() -> Bool {
        

        guard !self.isLoading, !self.isUpdating,
              let user = self.authService.currentUser,
              self.loadedUserId == user.id else { return false }

        let currentName = "\(user.firstName.trimmed()) \(user.lastName.trimmed())".trimmed()

        return !self.displayName.isEmpty
            && self.displayName.count <= 120
            && self.displayName != currentName
        
    }

    private func bindSubscribers() {

        guard self.cancelBag == nil else { return }
        self.cancelBag = CancelBag()

    }

    private var displayName: String {
        "\(self.firstName.trimmed()) \(self.lastName.trimmed())".trimmed()
    }

    private func populateProfile(user: LLUser) {

        self.loadedUserId = user.id
        self.firstName = user.firstName
        self.lastName = user.lastName
        self.email = user.email

    }

    private func presentProfileError(context: Constants.Message.Context) {

        self.alertService.showAlert(.init(
            .appAlert(
                .error(
                    message: Constants.Message.errorMessage(context: context, "profile"),
                    action: {}
                )
            )
        ))

    }
    
    private func cancelTasks() {
        
        self.loadDataTask?.cancel()
        self.updateTask?.cancel()
        
    }
    
}

extension ProfileViewModel {
    
    func track() {
        self.analyticsService.track(screen: .settings(.profile))
    }
    
}

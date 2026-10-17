import Combine
import SwiftUI

@MainActor
final class StoreAccountViewModel: ViewModel {

    let loggerName: String = "STORE_ACCOUNT_VIEW_MODEL"
    let loggerEmoji: String = "👤"

    private let apiService: APIServiceProtocol
    private let authService: AuthServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let alertService: AlertServiceProtocol

    private weak var navigationService: NavigationService?
    private var locationId: String?
    private var userSubscription: AnyCancellable?
    private var loadAccountTask: Task<Void, Never>?
    private var logoutTask: Task<Void, Never>?
    private var requestId: UUID?
    private var nextHistoryOffset: Int?

    @Published private(set) var user: LLUser?
    @Published private(set) var account: CustomerAccount?
    @Published private(set) var membership: CustomerLocationMembership?
    @Published private(set) var history: [LoyaltyHistoryEntry] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var isLoggingOut: Bool = false
    @Published private(set) var hasCompletedInitialLoad: Bool = false
    @Published private(set) var hasMoreHistory: Bool = false
    @Published private(set) var hasLoadFailed: Bool = false

    init(apiService: APIServiceProtocol,
         authService: AuthServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         alertService: AlertServiceProtocol) {
        self.apiService = apiService
        self.authService = authService
        self.analyticsService = analyticsService
        self.alertService = alertService

        logInit()

    }

    isolated deinit {

        self.loadAccountTask?.cancel()
        self.logoutTask?.cancel()
        self.userSubscription?.cancel()
        logDeinit()

    }

    @discardableResult
    func setup(locationId: String) -> Self {

        self.locationId = locationId
        return self

    }

    func setup(navigationService: NavigationService) {
        self.navigationService = navigationService
    }

    func handleFirstAppear() {

        track()
        bindSubscribers()

    }

    func presentSettings() {
        self.navigationService?.modal(fullScreenCover: .settings)
    }

    func register() {
        self.navigationService?.push(.auth(.signup))
    }

    func login() {
        self.navigationService?.push(.auth(.login))
    }

    func logout() {

        guard self.logoutTask == nil else { return }

        let authService = self.authService
        let alertService = self.alertService
        self.isLoggingOut = true

        self.logoutTask = Task { @MainActor [weak self] in

            guard !Task.isCancelled else { return }

            let loadingIndicator = RuneAlert(.simpleLoadingIndicator)
            alertService.showAlert(loadingIndicator)

            defer {

                alertService.dismissAlert(loadingIndicator)

                self?.isLoggingOut = false
                self?.logoutTask = nil

            }

            do {

                try await authService.logout()
                guard !Task.isCancelled else { return }

            } catch {

                guard !Task.isCancelled else { return }
                self?.presentSignOutError()

            }

        }

    }

    func loadData(showHud: Bool) {

        let user = self.authService.currentUser

        if self.user != user {
            updateUser(user)
        }

        loadAccount(shouldJoin: false, showHud: showHud)

    }

    func joinMembership() {

        guard self.membership == nil else { return }
        loadAccount(shouldJoin: true, showHud: true)

    }

    func loadMoreHistory(showHud: Bool = true) {

        guard self.loadAccountTask == nil,
              let locationId = self.locationId,
              let offset = self.nextHistoryOffset,
              self.hasMoreHistory else { return }

        let apiService = self.apiService
        let alertService = self.alertService
        let requestId = UUID()
        self.requestId = requestId
        self.isLoading = true

        self.loadAccountTask = Task { @MainActor [weak self] in

            guard !Task.isCancelled else { return }

            let loadingIndicator = RuneAlert(.simpleLoadingIndicator)
            if showHud { alertService.showAlert(loadingIndicator) }

            defer {

                if showHud { alertService.dismissAlert(loadingIndicator) }

                if self?.requestId == requestId {

                    self?.isLoading = false
                    self?.loadAccountTask = nil

                }

            }

            do {

                let history = try await apiService.getCustomerLoyaltyHistory(locationId: locationId, offset: offset)
                guard !Task.isCancelled, self?.requestId == requestId else { return }

                let existingIds = Set(self?.history.map(\.id) ?? [])
                self?.history.append(contentsOf: history.data.filter { !existingIds.contains($0.id) })
                self?.nextHistoryOffset = history.page.nextOffset
                self?.hasMoreHistory = history.page.hasMore && (history.page.nextOffset ?? offset) > offset

            } catch {

                guard !Task.isCancelled, self?.requestId == requestId else { return }
                self?.presentAccountError(context: .get)

            }

        }

    }

    private func loadAccount(shouldJoin: Bool, showHud: Bool) {

        guard self.loadAccountTask == nil, self.user != nil else { return }

        let locationId = self.locationId

        let apiService = self.apiService
        let alertService = self.alertService
        let requestId = UUID()
        self.requestId = requestId
        self.isLoading = true
        self.hasLoadFailed = false

        self.loadAccountTask = Task { @MainActor [weak self] in

            guard !Task.isCancelled else { return }

            let loadingIndicator = RuneAlert(.simpleLoadingIndicator)
            if showHud { alertService.showAlert(loadingIndicator) }

            defer {

                if showHud { alertService.dismissAlert(loadingIndicator) }

                if self?.requestId == requestId {

                    self?.isLoading = false
                    self?.loadAccountTask = nil

                }

            }

            do {

                let account = try await apiService.getCustomerAccount()
                guard !Task.isCancelled, self?.requestId == requestId else { return }

                self?.account = account

                guard let locationId else {

                    self?.membership = nil
                    self?.history = []
                    self?.hasMoreHistory = false
                    self?.hasCompletedInitialLoad = true
                    return

                }

                let membership: CustomerLocationMembership

                do {

                    membership = shouldJoin
                        ? try await apiService.joinCustomerMembership(locationId: locationId)
                        : try await apiService.getCustomerMembership(locationId: locationId)
                    guard !Task.isCancelled, self?.requestId == requestId else { return }

                } catch APIError.serverError(let statusCode, _) where statusCode == 404 && !shouldJoin {

                    guard !Task.isCancelled, self?.requestId == requestId else { return }
                    self?.membership = nil
                    self?.history = []
                    self?.hasMoreHistory = false
                    self?.hasCompletedInitialLoad = true
                    return

                }

                self?.membership = membership

                let history = try await apiService.getCustomerLoyaltyHistory(locationId: locationId, offset: 0)
                guard !Task.isCancelled, self?.requestId == requestId else { return }

                self?.history = history.data
                self?.nextHistoryOffset = history.page.nextOffset
                self?.hasMoreHistory = history.page.hasMore && history.page.nextOffset != nil
                self?.hasCompletedInitialLoad = true

            } catch {

                guard !Task.isCancelled, self?.requestId == requestId else { return }
                self?.hasLoadFailed = true
                self?.presentAccountError(context: .get)

            }

        }

    }

    private func updateUser(_ user: LLUser?) {

        self.loadAccountTask?.cancel()
        self.loadAccountTask = nil
        self.requestId = nil
        self.user = user
        self.account = nil
        self.membership = nil
        self.history = []
        self.isLoading = false
        self.hasMoreHistory = false
        self.hasCompletedInitialLoad = false
        self.hasLoadFailed = false
        self.nextHistoryOffset = nil

    }

    private func bindSubscribers() {

        guard self.userSubscription == nil else { return }

        self.userSubscription = self.authService.currentUserPublisher
            .removeDuplicates()
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.handleUserChange($0) }

    }

    private func handleUserChange(_ user: LLUser?) {

        guard self.authService.currentUser == user,
              self.user != user else { return }

        updateUser(user)

        if user != nil {

            self.navigationService?.popToRoot()
            loadData(showHud: true)

        }

    }

    private func presentAccountError(context: Constants.Message.Context) {

        self.alertService.showAlert(.init(
            .appAlert(
                .error(
                    message: Constants.Message.errorMessage(context: context, "account details"),
                    action: {}
                )
            )
        ))

    }

    private func presentSignOutError() {

        self.alertService.showAlert(.init(
            .appAlert(
                .error(
                    message: String(localized: "Unable to sign out. Please try again."),
                    action: {}
                )
            )
        ))

    }

}

extension StoreAccountViewModel {

    func track() {

        guard let locationId = self.locationId else { return }
        self.analyticsService.track(screen: .customer(.account(locationId: locationId)))

    }

}

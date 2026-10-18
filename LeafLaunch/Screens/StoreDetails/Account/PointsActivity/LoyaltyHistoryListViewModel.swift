//
//  LoyaltyHistoryListViewModel.swift
//  LeafLaunch
//
//  Created by KC Gunderson on 10/17/26.
//

import Combine
import SwiftUI

@MainActor
final class LoyaltyHistoryListViewModel: ViewModel {

    let loggerName: String = "LOYALTY_HISTORY_LIST_VIEW_MODEL"
    let loggerEmoji: String = "✨"

    private let apiService: APIServiceProtocol
    private let authService: AuthServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let alertService: AlertServiceProtocol

    private weak var navigationService: NavigationService?
    private var locationId: String?
    private var loadedUserId: String?
    private var userSubscription: AnyCancellable?
    private var loadHistoryTask: Task<Void, Never>?
    private var requestId: UUID?
    private var nextOffset: Int?
    private var shouldRetryFromStart: Bool = true

    @Published private(set) var history: [LoyaltyHistoryEntry] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var hasCompletedInitialLoad: Bool = false
    @Published private(set) var hasLoadFailed: Bool = false
    @Published private(set) var hasMoreHistory: Bool = false

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

        self.loadHistoryTask?.cancel()
        self.userSubscription?.cancel()
        logDeinit()

    }

    @discardableResult
    func setup(locationId: String) -> Self {

        self.locationId = locationId
        self.loadedUserId = self.authService.currentUser?.id
        return self

    }

    func setup(navigationService: NavigationService) {
        self.navigationService = navigationService
    }

    func handleFirstAppear() {

        track()
        bindSubscribers()

    }

    func loadData(showHud: Bool) {
        loadHistory(reset: true, showHud: showHud)
    }

    func loadMore() {

        guard self.hasMoreHistory else { return }
        loadHistory(reset: false, showHud: false)

    }

    func retry() {
        loadHistory(reset: self.shouldRetryFromStart, showHud: false)
    }

    func dismiss() {
        self.navigationService?.pop()
    }

    private func loadHistory(reset: Bool, showHud: Bool) {

        guard self.loadHistoryTask == nil, let locationId = self.locationId else { return }
        guard let userId = self.authService.currentUser?.id, userId == self.loadedUserId else {

            clearHistory()
            self.navigationService?.popToRoot()
            return

        }
        guard reset || self.nextOffset != nil else { return }

        let apiService = self.apiService
        let authService = self.authService
        let alertService = self.alertService
        let requestId = UUID()
        let offset = reset ? 0 : (self.nextOffset ?? 0)
        let refreshCount = max(1, self.history.count)
        self.requestId = requestId
        self.shouldRetryFromStart = reset
        self.isLoading = true
        self.hasLoadFailed = false

        self.loadHistoryTask = Task { @MainActor [weak self] in

            guard !Task.isCancelled else { return }

            let loadingIndicator = RuneAlert(.simpleLoadingIndicator)
            if showHud { alertService.showAlert(loadingIndicator) }

            defer {

                if showHud { alertService.dismissAlert(loadingIndicator) }

                if self?.requestId == requestId {

                    self?.isLoading = false
                    self?.loadHistoryTask = nil

                }

            }

            do {

                var page = try await apiService.getCustomerLoyaltyHistory(locationId: locationId, offset: offset)
                guard !Task.isCancelled, self?.requestId == requestId, authService.currentUser?.id == userId else { return }

                var receivedHistory = page.data
                var pageOffset = offset

                while reset, receivedHistory.count < refreshCount, page.page.hasMore, !page.data.isEmpty {

                    guard let nextOffset = page.page.nextOffset, nextOffset > pageOffset else { break }
                    pageOffset = nextOffset

                    page = try await apiService.getCustomerLoyaltyHistory(locationId: locationId, offset: pageOffset)
                    guard !Task.isCancelled, self?.requestId == requestId, authService.currentUser?.id == userId else { return }
                    receivedHistory.append(contentsOf: page.data)

                }

                var seenIds = Set(reset ? [] : (self?.history.map(\.id) ?? []))
                let loadedHistory = receivedHistory.filter { seenIds.insert($0.id).inserted }

                if reset {
                    self?.history = loadedHistory
                } else {
                    self?.history.append(contentsOf: loadedHistory)
                }

                self?.nextOffset = page.page.nextOffset
                self?.hasMoreHistory = page.page.hasMore && !page.data.isEmpty && (page.page.nextOffset ?? pageOffset) > pageOffset
                self?.hasCompletedInitialLoad = true

            } catch {

                guard !Task.isCancelled, self?.requestId == requestId, authService.currentUser?.id == userId else { return }
                self?.hasLoadFailed = true
                self?.presentHistoryError()

            }

        }

    }

    private func bindSubscribers() {

        guard self.userSubscription == nil else { return }

        self.userSubscription = self.authService.currentUserPublisher
            .map { $0?.id }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userId in self?.handleUserChange(userId) }

    }

    private func handleUserChange(_ userId: String?) {

        guard self.authService.currentUser?.id == userId, self.loadedUserId != userId else { return }

        clearHistory()
        self.loadedUserId = userId
        self.navigationService?.popToRoot()

    }

    private func clearHistory() {

        self.loadHistoryTask?.cancel()
        self.loadHistoryTask = nil
        self.requestId = nil
        self.nextOffset = nil
        self.history = []
        self.isLoading = false
        self.hasCompletedInitialLoad = false
        self.hasLoadFailed = false
        self.hasMoreHistory = false

    }

    private func presentHistoryError() {

        self.alertService.showAlert(.init(
            .appAlert(.error(
                message: Constants.Message.errorMessage(context: .get, "points activity"),
                action: {}
            ))
        ))

    }

}

extension LoyaltyHistoryListViewModel {

    func track() {

        guard let locationId = self.locationId else { return }
        self.analyticsService.track(screen: .customer(.pointsActivity(locationId: locationId)))

    }

}

import SwiftUI

@MainActor
final class StoreEventsViewModel: ViewModel {

    let loggerName: String = "STORE_EVENTS_VIEW_MODEL"
    let loggerEmoji: String = "📅"

    private let apiService: APIServiceProtocol
    private let storeSessionService: StoreSessionServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let alertService: AlertServiceProtocol

    private weak var navigationService: NavigationService?
    private var locationId: String?
    private var loadEventsTask: Task<Void, Never>?
    private var nextOffset: Int?

    @Published private(set) var events: [StoreEvent] = []
    @Published private(set) var isLoading = false
    @Published private(set) var hasCompletedInitialLoad = false
    @Published private(set) var hasLoadFailed = false
    @Published private(set) var hasMoreEvents = false

    var location: StoreLocation? {

        guard let location = self.storeSessionService.locationDetails?.location,
              location.id == self.locationId else { return nil }
        return location

    }

    init(apiService: APIServiceProtocol,
         storeSessionService: StoreSessionServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         alertService: AlertServiceProtocol) {

        self.apiService = apiService
        self.storeSessionService = storeSessionService
        self.analyticsService = analyticsService
        self.alertService = alertService

        logInit()

    }

    isolated deinit {

        self.loadEventsTask?.cancel()
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
    }

    func loadData(showHud: Bool) {
        loadEvents(reset: true, showHud: showHud)
    }

    func loadMore() {

        guard self.hasMoreEvents else { return }
        loadEvents(reset: false, showHud: false)

    }

    func openEvent(_ event: StoreEvent) {

        guard let locationId = self.locationId,
              self.events.contains(where: { $0.id == event.id }) else { return }
        self.navigationService?.push(.customer(.event(locationId: locationId, event: event)))

    }

    func dismiss() {
        self.navigationService?.pop()
    }

    private func loadEvents(reset: Bool, showHud: Bool) {

        guard self.loadEventsTask == nil, let locationId = self.locationId else { return }
        guard reset || self.nextOffset != nil else { return }

        let apiService = self.apiService
        let alertService = self.alertService
        let offset = reset ? 0 : (self.nextOffset ?? 0)
        let refreshCount = max(20, self.events.count)
        let limit = reset ? min(100, refreshCount) : 20
        self.isLoading = true
        self.hasLoadFailed = false

        self.loadEventsTask = Task { @MainActor [weak self] in

            guard !Task.isCancelled else { return }

            let loadingIndicator = RuneAlert(.simpleLoadingIndicator)
            if showHud { alertService.showAlert(loadingIndicator) }

            defer {

                if showHud { alertService.dismissAlert(loadingIndicator) }

                self?.isLoading = false
                self?.loadEventsTask = nil

            }

            do {

                var page = try await apiService.getCustomerEvents(locationId: locationId, offset: offset, limit: limit)
                guard !Task.isCancelled else { return }

                var receivedEvents = page.data
                var pageOffset = offset

                while reset, receivedEvents.count < refreshCount, page.page.hasMore {

                    guard let nextOffset = page.page.nextOffset, nextOffset > pageOffset else { break }
                    pageOffset = nextOffset

                    page = try await apiService.getCustomerEvents(
                        locationId: locationId,
                        offset: pageOffset,
                        limit: min(100, refreshCount - receivedEvents.count)
                    )
                    guard !Task.isCancelled else { return }
                    receivedEvents.append(contentsOf: page.data)

                }

                var seenIds = Set(reset ? [] : (self?.events.map(\.id) ?? []))
                let loadedEvents = receivedEvents.filter { seenIds.insert($0.id).inserted }

                if reset {
                    self?.events = loadedEvents
                } else {
                    self?.events.append(contentsOf: loadedEvents)
                }

                self?.nextOffset = page.page.nextOffset
                self?.hasMoreEvents = page.page.hasMore && (page.page.nextOffset ?? pageOffset) > pageOffset
                self?.hasCompletedInitialLoad = true

            } catch {

                guard !Task.isCancelled else { return }
                self?.hasLoadFailed = true
                self?.presentEventsError()

            }

        }

    }

    private func presentEventsError() {

        self.alertService.showAlert(.init(
            .appAlert(
                .error(
                    message: Constants.Message.errorMessage(context: .get, "events"),
                    action: {}
                )
            )
        ))

    }

}

extension StoreEventsViewModel {

    func track() {

        guard let locationId = self.locationId else { return }
        self.analyticsService.track(screen: .customer(.events(locationId: locationId)))

    }

}

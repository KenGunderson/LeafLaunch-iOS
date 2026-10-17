import SwiftUI

@MainActor
final class StoreOverviewViewModel: ViewModel {

    let loggerName: String = "STORE_OVERVIEW_VIEW_MODEL"
    let loggerEmoji: String = "🏪"

    private let apiService: APIServiceProtocol
    private let storeSessionService: StoreSessionServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let alertService: AlertServiceProtocol

    private weak var navigationService: NavigationService?
    private var locationId: String?
    private var loadOverviewTask: Task<Void, Never>?
    private var loadEventsTask: Task<Void, Never>?
    private var nextEventsOffset: Int?

    @Published private(set) var promotions: [Promotion] = []
    @Published private(set) var events: [StoreEvent] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var isLoadingEvents: Bool = false
    @Published private(set) var hasCompletedInitialLoad: Bool = false
    @Published private(set) var hasMoreEvents: Bool = false

    var configuration: CustomerBootstrap? { self.storeSessionService.configuration }
    var store: PublicStore? { self.storeSessionService.store }
    var locationDetails: CustomerLocationDetails? { self.storeSessionService.locationDetails }

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

        self.loadOverviewTask?.cancel()
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

        guard self.loadOverviewTask == nil, self.loadEventsTask == nil,
              let locationId = self.locationId else { return }

        let apiService = self.apiService
        let alertService = self.alertService
        self.isLoading = true

        self.loadOverviewTask = Task { @MainActor [weak self] in

            guard !Task.isCancelled else { return }

            let loadingIndicator = RuneAlert(.simpleLoadingIndicator)
            if showHud { alertService.showAlert(loadingIndicator) }

            defer {

                if showHud { alertService.dismissAlert(loadingIndicator) }

                self?.isLoading = false
                self?.loadOverviewTask = nil

            }

            do {

                async let promotions = apiService.getCustomerPromotions(locationId: locationId)
                async let events = apiService.getCustomerEvents(locationId: locationId, offset: 0)
                let (loadedPromotions, loadedEvents) = try await (promotions, events)
                guard !Task.isCancelled else { return }

                self?.promotions = loadedPromotions
                self?.events = loadedEvents.data
                self?.nextEventsOffset = loadedEvents.page.nextOffset
                self?.hasMoreEvents = loadedEvents.page.hasMore && loadedEvents.page.nextOffset != nil
                self?.hasCompletedInitialLoad = true

            } catch {

                guard !Task.isCancelled else { return }
                self?.presentOverviewError(context: .get)

            }

        }

    }

    func loadMoreEvents(showHud: Bool = true) {

        guard self.loadOverviewTask == nil, self.loadEventsTask == nil,
              let locationId = self.locationId,
              let offset = self.nextEventsOffset,
              self.hasMoreEvents else { return }

        let apiService = self.apiService
        let alertService = self.alertService
        self.isLoadingEvents = true

        self.loadEventsTask = Task { @MainActor [weak self] in

            guard !Task.isCancelled else { return }

            let loadingIndicator = RuneAlert(.simpleLoadingIndicator)
            if showHud { alertService.showAlert(loadingIndicator) }

            defer {

                if showHud { alertService.dismissAlert(loadingIndicator) }

                self?.isLoadingEvents = false
                self?.loadEventsTask = nil

            }

            do {

                let events = try await apiService.getCustomerEvents(locationId: locationId, offset: offset)
                guard !Task.isCancelled else { return }

                let existingIds = Set(self?.events.map(\.id) ?? [])
                self?.events.append(contentsOf: events.data.filter { !existingIds.contains($0.id) })
                self?.nextEventsOffset = events.page.nextOffset
                self?.hasMoreEvents = events.page.hasMore && (events.page.nextOffset ?? offset) > offset

            } catch {

                guard !Task.isCancelled else { return }
                self?.presentOverviewError(context: .get)

            }

        }

    }

    func changeLocation() {
        self.storeSessionService.showLocations()
    }

    func openProduct(_ product: PromotionLinkedProduct) {

        guard let locationId = self.locationId,
              product.storeLocationId == locationId else { return }

        self.navigationService?.push(.customer(.product(locationId: locationId, productId: product.id)))

    }

    private func presentOverviewError(context: Constants.Message.Context) {

        self.alertService.showAlert(.init(
            .appAlert(
                .error(
                    message: Constants.Message.errorMessage(context: context, "store information"),
                    action: {}
                )
            )
        ))

    }

}

extension StoreOverviewViewModel {

    func track() {

        guard let locationId = self.locationId else { return }
        self.analyticsService.track(screen: .customer(.overview(locationId: locationId)))

    }

}

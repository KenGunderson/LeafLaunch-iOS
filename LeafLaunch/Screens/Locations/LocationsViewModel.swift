import Combine
import SwiftUI

@MainActor
final class LocationsViewModel: ViewModel {

    let loggerName: String = "LOCATIONS_VIEW_MODEL"
    let loggerEmoji: String = "📍"

    private let storeSessionService: StoreSessionServiceProtocol
    private let apiService: APIServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let alertService: AlertServiceProtocol

    private weak var navigationService: NavigationService?
    private var sessionSubscription: AnyCancellable?
    private var loadingIndicator: RuneAlert?
    private var lastPresentedErrorMessage: String?
    private var loadLocationsTask: Task<Void, Never>?

    @Published private(set) var locations: [BootstrapLocation] = []
    @Published private(set) var locationDetails: [String: CustomerLocationDetails] = [:]
    @Published private(set) var failedLocationIds: Set<String> = []
    @Published private(set) var isLoading: Bool = false

    var configuration: CustomerBootstrap? { self.storeSessionService.configuration }

    init(storeSessionService: StoreSessionServiceProtocol,
         apiService: APIServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         alertService: AlertServiceProtocol) {

        self.storeSessionService = storeSessionService
        self.apiService = apiService
        self.analyticsService = analyticsService
        self.alertService = alertService

        logInit()

    }

    isolated deinit {

        self.sessionSubscription?.cancel()
        self.loadLocationsTask?.cancel()

        if let loadingIndicator = self.loadingIndicator {
            self.alertService.dismissAlert(loadingIndicator)
        }

        logDeinit()

    }

    func setup(navigationService: NavigationService) {
        self.navigationService = navigationService
    }

    func handleFirstAppear() {

        track()
        bindSubscribers()

    }

    func selectLocation(id: String) {
        self.storeSessionService.selectLocation(id: id)
    }

    func loadData(showHud: Bool) {

        self.loadLocationsTask?.cancel()

        let locationIds = self.storeSessionService.locations.map(\.id)
        guard !locationIds.isEmpty else {

            self.isLoading = false
            self.loadLocationsTask = nil
            return

        }

        let apiService = self.apiService
        let alertService = self.alertService
        let businessId = BusinessConfig.businessId
        self.isLoading = true
        self.failedLocationIds = []

        self.loadLocationsTask = Task { @MainActor [weak self] in

            guard !Task.isCancelled else { return }

            let loadingIndicator = RuneAlert(.simpleLoadingIndicator)
            if showHud { alertService.showAlert(loadingIndicator) }

            defer {

                if showHud { alertService.dismissAlert(loadingIndicator) }

                if !Task.isCancelled {

                    self?.isLoading = false
                    self?.loadLocationsTask = nil

                }

            }

            await withTaskGroup(of: (String, CustomerLocationDetails?).self) { group in

                for locationId in locationIds {

                    group.addTask {

                        do {

                            let details = try await apiService.getCustomerLocation(
                                businessId: businessId,
                                locationId: locationId
                            )
                            try Task.checkCancellation()
                            return (locationId, details)

                        } catch {
                            return (locationId, nil)
                        }

                    }

                }

                for await (locationId, details) in group {

                    guard !Task.isCancelled else {

                        group.cancelAll()
                        return

                    }

                    if let details {
                        self?.locationDetails[locationId] = details
                    } else {
                        self?.failedLocationIds.insert(locationId)
                    }

                }

            }

            guard !Task.isCancelled else { return }

            if self?.failedLocationIds.isEmpty == false {
                self?.presentLocationError(context: .get)
            }

        }

    }

    private func bindSubscribers() {

        guard self.sessionSubscription == nil else { return }

        self.sessionSubscription = self.storeSessionService.statePublisher
            .sink { [weak self] state in

                self?.locations = self?.storeSessionService.locations ?? []
                self?.handleSessionState(state)

            }

    }

    private func handleSessionState(_ state: StoreSessionState) {

        if state == .loading {

            self.lastPresentedErrorMessage = nil

            if self.loadingIndicator == nil {

                let loadingIndicator = RuneAlert(.simpleLoadingIndicator)
                self.loadingIndicator = loadingIndicator
                self.alertService.showAlert(loadingIndicator)

            }

        } else if let loadingIndicator = self.loadingIndicator {

            self.alertService.dismissAlert(loadingIndicator)
            self.loadingIndicator = nil

        }

        guard state == .locations,
              let error = self.storeSessionService.error else { return }

        let errorMessage = error.getMessageForError()
        guard self.lastPresentedErrorMessage != errorMessage else { return }

        self.lastPresentedErrorMessage = errorMessage
        presentLocationError(context: .get)

    }

    private func presentLocationError(context: Constants.Message.Context) {

        self.alertService.showAlert(.init(
            .appAlert(
                .error(
                    message: Constants.Message.errorMessage(context: context, "location"),
                    action: {}
                )
            )
        ))

    }

}

extension LocationsViewModel {

    func track() {
        self.analyticsService.track(screen: .customer(.locations(businessId: BusinessConfig.businessId)))
    }

}

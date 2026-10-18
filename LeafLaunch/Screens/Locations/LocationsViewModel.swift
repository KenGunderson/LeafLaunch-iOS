import Combine
import CoreLocation
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
    private var locationSearchLocator: LocationSearchLocator?

    @Published private(set) var locations: [BootstrapLocation] = []
    @Published private(set) var locationDetails: [String: CustomerLocationDetails] = [:]
    @Published private(set) var failedLocationIds: Set<String> = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var selectedLocationId: String?
    @Published private(set) var isContinuing: Bool = false
    @Published private(set) var isLocating: Bool = false
    @Published private(set) var canDismiss: Bool = false
    @Published var search: String = "" {
        didSet { cancelLocationSearch() }
    }

    var configuration: CustomerBootstrap? { self.storeSessionService.configuration }

    var selectedLocation: BootstrapLocation? {
        return self.locations.first { $0.id == self.selectedLocationId }
    }

    var canContinue: Bool { self.selectedLocation != nil && !self.isContinuing }

    var filteredLocations: [BootstrapLocation] {

        let terms = self.search.split(whereSeparator: { $0.isWhitespace }).map(String.init)
        guard !terms.isEmpty else { return self.locations }

        return self.locations.filter { location in

            let details = self.locationDetails[location.id]
            let searchableText = [location.name, location.region, details?.address, details?.location.city, details?.location.postalCode]
                .compactMap { $0 }
                .joined(separator: " ")

            return terms.allSatisfy { searchableText.localizedStandardContains($0) }

        }

    }

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
        self.locationSearchLocator?.cancel()

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

        guard !self.isContinuing, self.locations.contains(where: { $0.id == id }) else { return }
        self.selectedLocationId = id

    }

    func continueToLocation() {

        guard self.canContinue, let selectedLocationId = self.selectedLocationId else { return }

        cancelLocationSearch()
        self.isContinuing = true
        self.storeSessionService.selectLocation(id: selectedLocationId)

    }

    func dismiss() {

        guard self.canDismiss else { return }
        cancelLocationSearch()
        self.storeSessionService.cancelLocationSelection()

    }

    func clearSearch() {

        cancelLocationSearch()
        self.search = ""

    }

    func useCurrentLocation() {

        guard !self.isLocating, !self.isContinuing else { return }

        let locator = LocationSearchLocator()
        self.locationSearchLocator = locator
        self.isLocating = true

        locator.findCity { [weak self] result in

            guard let self else { return }
            self.isLocating = false
            self.locationSearchLocator = nil

            switch result {
            case .success(let city):
                self.search = city
            case .failure(let error):
                self.presentLocationSearchError(error)
            }

        }

    }

    func cancelLocationSearch() {

        self.locationSearchLocator?.cancel()
        self.locationSearchLocator = nil
        self.isLocating = false

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
                self?.canDismiss = state == .locations && self?.storeSessionService.canDismissLocationSelection == true
                self?.restoreSelectionIfNeeded()
                self?.handleSessionState(state)

            }

    }

    private func handleSessionState(_ state: StoreSessionState) {

        self.isContinuing = state == .loading

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

    private func restoreSelectionIfNeeded() {

        if let selectedLocationId = self.selectedLocationId,
           self.locations.contains(where: { $0.id == selectedLocationId }) { return }

        let currentLocationId = self.storeSessionService.locationDetails?.location.id
        self.selectedLocationId = self.locations.first { $0.id == currentLocationId }?.id

        if self.selectedLocationId == nil, self.locations.count == 1 {
            self.selectedLocationId = self.locations.first?.id
        }

    }

    private func presentLocationSearchError(_ error: Error) {

        let isDenied = (error as? CLError)?.code == .denied
        let message = isDenied
            ? Constants.Message.locationSearchDeniedMessage
            : Constants.Message.locationSearchErrorMessage

        self.alertService.showAlert(.init(
            .appAlert(.error(message: message, action: {}))
        ))

    }

}

extension LocationsViewModel {

    func track() {
        self.analyticsService.track(screen: .customer(.locations(businessId: BusinessConfig.businessId)))
    }

}

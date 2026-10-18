import Combine
import CoreLocation
import SwiftUI

@MainActor
final class LocationListViewModel: ViewModel {

    let loggerName: String = "LOCATION_LIST_VIEW_MODEL"
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
    private var nearbySearchLocator: LocationSearchLocator?
    private var nearbySearchTask: Task<Void, Never>?
    private var locationSearchId: UUID?
    private var searchCenter: CLLocation?
    private var coordinatesByAddress: [String: CLLocation] = [:]
    private var hasAttemptedLocationPrefill: Bool = false
    private var shouldPresentSearchErrors: Bool = true

    @Published private(set) var locations: [BootstrapLocation] = []
    @Published private(set) var locationDetails: [String: CustomerLocationDetails] = [:]
    @Published private(set) var failedLocationIds: Set<String> = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var selectedLocationId: String?
    @Published private(set) var isContinuing: Bool = false
    @Published private(set) var isLocating: Bool = false
    @Published private(set) var canDismiss: Bool = false
    @Published private(set) var isSearchingNearby: Bool = false
    @Published private(set) var locationDistances: [String: CLLocationDistance] = [:]
    @Published private(set) var step: LocationSelectionStep = .locationSelection
    @Published private(set) var isApproving: Bool = false
    @Published var search: String = "" {
        didSet { handleSearchChange() }
    }

    var configuration: CustomerBootstrap? { self.storeSessionService.configuration }

    var selectedLocation: BootstrapLocation? {
        return self.locations.first { $0.id == self.selectedLocationId }
    }

    var canContinue: Bool { self.selectedLocation != nil && !self.isContinuing }

    var minimumAge: Int { self.storeSessionService.minimumAge }

    var ageVerificationDetails: CustomerLocationDetails? {

        guard case .ageVerification(let locationId) = self.step,
              let details = self.storeSessionService.ageVerificationDetails,
              details.location.id == locationId else { return nil }
        return details

    }

    private var postalCodeQuery: String? {
        postalCode(from: self.search)
    }

    var filteredLocations: [BootstrapLocation] {

        if self.searchCenter != nil || self.postalCodeQuery != nil {

            return self.locations.enumerated().sorted { lhs, rhs in

                let leftDistance = self.locationDistances[lhs.element.id] ?? .infinity
                let rightDistance = self.locationDistances[rhs.element.id] ?? .infinity
                return leftDistance == rightDistance ? lhs.offset < rhs.offset : leftDistance < rightDistance

            }
            .map(\.element)

        }

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
        self.nearbySearchTask?.cancel()
        self.nearbySearchLocator?.cancel()

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

    func submitSearch() {

        guard self.postalCodeQuery != nil, !self.isContinuing else { return }
        self.shouldPresentSearchErrors = true
        cancelLocationSearch()
        searchNearby(debounce: false)

    }

    func useCurrentLocation() {

        self.hasAttemptedLocationPrefill = true
        locateCurrentLocation(using: LocationSearchLocator(), isAutomatic: false)

    }

    func cancelLocationSearch() {

        self.locationSearchId = nil
        self.locationSearchLocator?.cancel()
        self.locationSearchLocator = nil
        self.nearbySearchTask?.cancel()
        self.nearbySearchTask = nil
        self.nearbySearchLocator?.cancel()
        self.nearbySearchLocator = nil
        self.isLocating = false
        self.isSearchingNearby = false
        self.searchCenter = nil
        self.locationDistances = [:]

    }

    func cancelLocationSelectionWork() {

        cancelLocationSearch()
        cancelLocationDetailsLoad()

    }

    func approveAgeVerification() {

        guard !self.isApproving,
              case .ageVerification(let locationId) = self.step,
              self.storeSessionService.state == .ageVerification,
              self.storeSessionService.ageVerificationLocationId == locationId else { return }

        self.isApproving = true

        do {
            try self.storeSessionService.approveAgeVerification()
        } catch {

            self.isApproving = false
            presentAgeVerificationError()

        }

    }

    func changeLocation() {

        guard !self.isApproving,
              case .ageVerification(let locationId) = self.step,
              self.storeSessionService.state == .ageVerification,
              self.storeSessionService.ageVerificationLocationId == locationId else { return }
        self.storeSessionService.showLocations()

    }

    func loadData(showHud: Bool) {

        cancelLocationDetailsLoad()
        guard self.step == .locationSelection else { return }

        let locationIds = self.storeSessionService.locations.map(\.id)
        guard !locationIds.isEmpty else {

            self.isLoading = false
            self.loadLocationsTask = nil
            return

        }

        prefillSearchIfAuthorized()

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

            self?.refreshNearbyLocations()

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

        switch state {
        case .locations:

            if self.step != .locationSelection {

                self.step = .locationSelection
                track()

            }

            self.isApproving = false

        case .ageVerification:

            guard let locationId = self.storeSessionService.ageVerificationLocationId else { return }
            let step = LocationSelectionStep.ageVerification(locationId: locationId)

            if self.step != step {

                cancelLocationSelectionWork()
                self.step = step
                self.isApproving = false
                trackAgeVerification(locationId: locationId)

            }

        default:
            break
        }

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

    private func prefillSearchIfAuthorized() {

        guard !self.hasAttemptedLocationPrefill,
              self.search.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !self.isLocating,
              !self.isContinuing else { return }

        let locator = LocationSearchLocator()
        guard locator.isAuthorized else { return }

        self.hasAttemptedLocationPrefill = true
        locateCurrentLocation(using: locator, isAutomatic: true)

    }

    private func locateCurrentLocation(using locator: LocationSearchLocator, isAutomatic: Bool) {

        guard self.step == .locationSelection, !self.isLocating, !self.isContinuing else { return }
        cancelLocationSearch()

        let searchId = UUID()
        self.locationSearchId = searchId
        self.locationSearchLocator = locator
        self.isLocating = true

        locator.findLocation(requestAuthorization: !isAutomatic) { [weak self] result in

            guard let self, self.locationSearchId == searchId else { return }
            self.isLocating = false
            self.locationSearchLocator = nil

            switch result {
            case .success(let result):

                if let postalCode = result.postalCode.flatMap({ self.postalCode(from: $0) }) {

                    self.search = postalCode
                    self.shouldPresentSearchErrors = !isAutomatic
                    self.cancelLocationSearch()
                    self.searchNearby(debounce: false)

                } else {

                    self.search = ""
                    self.shouldPresentSearchErrors = !isAutomatic
                    self.searchNearby(center: result.location, debounce: false)

                }

            case .failure(let error):

                guard !isAutomatic, !(error is CancellationError) else { return }

                if self.postalCodeQuery != nil {
                    self.submitSearch()
                }

                self.presentLocationSearchError(error)

            }

        }

    }

    private func cancelLocationDetailsLoad() {

        self.loadLocationsTask?.cancel()
        self.loadLocationsTask = nil
        self.isLoading = false

    }

    private func handleSearchChange() {

        self.hasAttemptedLocationPrefill = true
        self.shouldPresentSearchErrors = true
        cancelLocationSearch()
        guard self.postalCodeQuery != nil else { return }
        searchNearby(debounce: true)

    }

    private func refreshNearbyLocations() {

        guard self.step == .locationSelection,
              !self.isLocating,
              self.searchCenter != nil || self.postalCodeQuery != nil else { return }
        self.nearbySearchTask?.cancel()
        self.nearbySearchLocator?.cancel()
        searchNearby(center: self.searchCenter, debounce: false)

    }

    private func searchNearby(center: CLLocation? = nil, debounce: Bool) {

        let searchId = UUID()
        let locator = LocationSearchLocator()
        let query = self.search
        let postalCode = self.postalCodeQuery
        let shouldPresentSearchErrors = self.shouldPresentSearchErrors
        let countryCode = self.locations.compactMap(\.countryCode).first ?? "US"
        self.locationSearchId = searchId
        self.nearbySearchLocator = locator
        self.locationDistances = [:]
        self.isSearchingNearby = true

        self.nearbySearchTask = Task { @MainActor [weak self] in

            defer {

                if self?.locationSearchId == searchId {

                    self?.isSearchingNearby = false
                    self?.nearbySearchTask = nil
                    self?.nearbySearchLocator = nil

                }

            }

            do {

                if debounce { try await Task.sleep(for: .milliseconds(300)) }
                try Task.checkCancellation()

                let resolvedCenter: CLLocation

                if let postalCode {
                    resolvedCenter = try await locator.geocode(address: "\(postalCode), \(countryCode)")
                } else if let center {
                    resolvedCenter = center
                } else {
                    return
                }

                guard !Task.isCancelled,
                      self?.locationSearchId == searchId,
                      self?.search == query else { return }

                self?.searchCenter = resolvedCenter

                let locations = self?.locations ?? []
                let detailsById = self?.locationDetails ?? [:]
                var attemptedGeocoding = false

                for location in locations {

                    try Task.checkCancellation()
                    guard self?.locationSearchId == searchId,
                          let details = detailsById[location.id] else { continue }
                    let address = details.address.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !address.isEmpty else { continue }
                    attemptedGeocoding = true

                    do {

                        let coordinate: CLLocation

                        if let cachedCoordinate = self?.coordinatesByAddress[address] {
                            coordinate = cachedCoordinate
                        } else {

                            coordinate = try await locator.geocode(address: address)
                            guard !Task.isCancelled, self?.locationSearchId == searchId else { return }
                            self?.coordinatesByAddress[address] = coordinate

                        }

                        self?.locationDistances[location.id] = coordinate.distance(from: resolvedCenter)

                    } catch {

                        guard !Task.isCancelled,
                              !(error is CancellationError),
                              self?.locationSearchId == searchId else { return }
                        // Keep stores whose addresses cannot be resolved after the ranked stores.

                    }

                }

                guard !Task.isCancelled, self?.locationSearchId == searchId else { return }

                if shouldPresentSearchErrors,
                   attemptedGeocoding,
                   self?.locationDistances.isEmpty == true,
                   self?.isLoading == false {
                    self?.presentLocationSearchError(CLError(.geocodeFoundNoResult))
                }

            } catch {

                guard !Task.isCancelled,
                      !(error is CancellationError),
                      self?.locationSearchId == searchId else { return }

                if shouldPresentSearchErrors {
                    self?.presentLocationSearchError(error)
                }

            }

        }

    }

    private func postalCode(from search: String) -> String? {

        let query = search.trimmingCharacters(in: .whitespacesAndNewlines)
        let parts = query.split(separator: "-", omittingEmptySubsequences: false)
        guard parts.count == 1 || parts.count == 2,
              parts[0].count == 5,
              parts[0].allSatisfy({ $0.isASCII && $0.isNumber }),
              parts.count == 1 || (parts[1].count == 4 && parts[1].allSatisfy({ $0.isASCII && $0.isNumber })) else { return nil }
        return String(parts[0])

    }

    private func presentAgeVerificationError() {

        self.alertService.showAlert(.init(
            .appAlert(.error(message: Constants.Message.ageVerificationErrorMessage, action: {}))
        ))

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

extension LocationListViewModel {

    func track() {
        self.analyticsService.track(screen: .customer(.locations(businessId: BusinessConfig.businessId)))
    }

    private func trackAgeVerification(locationId: String) {
        self.analyticsService.track(screen: .customer(.ageVerification(locationId: locationId)))
    }

}

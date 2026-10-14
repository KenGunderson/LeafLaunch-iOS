import Combine
import Foundation

@MainActor
final class StoreSessionService: StoreSessionServiceProtocol, Loggable {

    let loggerName: String = "STORE_SESSION_SERVICE"
    let loggerEmoji: String = "🏪"

    private let apiService: APIServiceProtocol
    private let authService: AuthServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol
    private let tabBarNavigationService: TabBarNavigationService

    private var userSubscription: AnyCancellable?
    private var selectLocationTask: Task<Void, Never>?
    private var selectionId: UUID?
    private var isBootstrapping: Bool = false

    private(set) var configuration: CustomerBootstrap?
    private(set) var locationDetails: CustomerLocationDetails?
    private(set) var error: Error?

    @Published private(set) var state: StoreSessionState = .loading

    var statePublisher: AnyPublisher<StoreSessionState, Never> {
        return self.$state.eraseToAnyPublisher()
    }

    var locations: [BootstrapLocation] {
        return self.configuration?.locations ?? []
    }

    var minimumAge: Int {
        return max(18, self.configuration?.minimumAge ?? 18)
    }

    var ageVerificationState: String {

        let location = self.locationDetails?.location
        let region = location?.region?.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if let region, !region.isEmpty { return region }

        // A missing region must never bypass a required gate.
        return "\(location?.countryCode ?? "UNKNOWN"):\(BusinessConfig.businessId)"

    }

    init(apiService: APIServiceProtocol,
         authService: AuthServiceProtocol,
         userDefaultsService: UserDefaultsServiceProtocol,
         tabBarNavigationService: TabBarNavigationService) {
        self.apiService = apiService
        self.authService = authService
        self.userDefaultsService = userDefaultsService
        self.tabBarNavigationService = tabBarNavigationService

        logInit()

    }

    isolated deinit {

        self.selectLocationTask?.cancel()
        self.userSubscription?.cancel()
        logDeinit()

    }

    func bootstrap() async {

        guard !self.isBootstrapping else { return }
        guard BusinessConfig.isConfigured else {

            self.state = .configurationRequired
            return

        }

        self.isBootstrapping = true
        self.selectLocationTask?.cancel()
        self.selectLocationTask = nil
        self.selectionId = nil
        self.error = nil
        self.locationDetails = nil
        self.state = .loading
        bindSubscribers()

        defer { self.isBootstrapping = false }

        do {

            let configuration = try await self.apiService.getCustomerBootstrap(appKey: BusinessConfig.appKey)
            guard !Task.isCancelled else { return }

            self.configuration = configuration
            self.userDefaultsService.applyStoreTheme(branding: configuration.branding)

            switch configuration.state {
            case .updateRequired:

                self.state = .updateRequired
                return

            case .unavailable:

                self.state = .unavailable
                return

            case .available:
                break
            }

            if let locationId = self.userDefaultsService.lastSelectedLocationId {

                do {

                    let details = try await self.apiService.getCustomerLocation(
                        businessId: BusinessConfig.businessId,
                        locationId: locationId
                    )
                    guard !Task.isCancelled else { return }
                    try validate(details: details, locationId: locationId)

                    self.locationDetails = details
                    evaluateAgeVerification()

                } catch {

                    guard !Task.isCancelled else { return }
                    self.userDefaultsService.set(lastSelectedLocationId: nil)
                    self.state = .locations

                }

                return

            }

            if let location = configuration.locations.first,
               configuration.locations.count == 1 {

                do {

                    let details = try await self.apiService.getCustomerLocation(
                        businessId: BusinessConfig.businessId,
                        locationId: location.id
                    )
                    guard !Task.isCancelled else { return }
                    try validate(details: details, locationId: location.id)

                    self.locationDetails = details
                    evaluateAgeVerification()

                } catch {

                    guard !Task.isCancelled else { return }
                    self.error = error
                    self.state = .locations

                }

            } else {
                self.state = .locations
            }

        } catch {

            guard !Task.isCancelled else { return }
            self.error = error
            self.state = .failed

        }

    }

    func selectLocation(id: String) {

        guard self.locations.contains(where: { $0.id.lowercased() == id.lowercased() }) else { return }

        self.selectLocationTask?.cancel()
        let selectionId = UUID()
        let apiService = self.apiService
        let businessId = BusinessConfig.businessId

        self.selectionId = selectionId
        self.error = nil
        self.locationDetails = nil
        self.state = .loading

        self.selectLocationTask = Task { [weak self] in

            defer {

                if self?.selectionId == selectionId {
                    self?.selectLocationTask = nil
                }

            }

            do {

                let details = try await apiService.getCustomerLocation(businessId: businessId, locationId: id)
                guard !Task.isCancelled, self?.selectionId == selectionId else { return }
                try self?.validate(details: details, locationId: id)

                self?.locationDetails = details
                self?.evaluateAgeVerification()

            } catch {

                guard !Task.isCancelled, self?.selectionId == selectionId else { return }
                self?.error = error
                self?.state = .locations

            }

        }

    }

    func showLocations() {

        self.selectLocationTask?.cancel()
        self.selectLocationTask = nil
        self.selectionId = nil
        self.locationDetails = nil
        self.error = nil
        self.tabBarNavigationService.resetPathItems()
        self.state = .locations

    }

    func approveAgeVerification() {

        guard self.state == .ageVerification, self.locationDetails != nil else { return }

        let userId = self.authService.currentUser?.id ?? self.userDefaultsService.guestIdentityId
        self.userDefaultsService.approveAge(userId: userId, state: self.ageVerificationState)
        evaluateAgeVerification()

    }

    private func validate(details: CustomerLocationDetails, locationId: String) throws {

        guard details.location.id.lowercased() == locationId.lowercased(),
              details.location.storeId.lowercased() == BusinessConfig.businessId.lowercased(),
              details.location.isAvailable,
              self.locations.contains(where: { $0.id.lowercased() == locationId.lowercased() }) else {
            throw StoreSessionError.invalidLocation
        }

    }

    private func evaluateAgeVerification() {

        guard let location = self.locationDetails?.location else { return }
        guard self.configuration?.state == .available else { return }

        let userId = self.authService.currentUser?.id ?? self.userDefaultsService.guestIdentityId
        let requiresApproval = self.configuration?.ageGateRequired == true &&
            !self.userDefaultsService.hasApprovedAge(userId: userId, state: self.ageVerificationState)

        self.userDefaultsService.set(lastSelectedLocationId: location.id)

        if requiresApproval {

            self.state = .ageVerification

        } else {

            self.tabBarNavigationService.initializeStoreExperience(locationId: location.id)
            self.state = .store

        }

    }

    private func bindSubscribers() {

        guard self.userSubscription == nil else { return }

        self.userSubscription = self.authService.currentUserPublisher
            .map { $0?.id }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.evaluateAgeVerification()
            }

    }

}

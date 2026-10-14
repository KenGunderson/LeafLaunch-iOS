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
    private var ageVerificationTask: Task<Void, Never>?
    private var acceptAgeTask: Task<AgeGateAcceptance, Error>?
    private var ageEvaluationId: UUID?
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

    var store: PublicStore? { self.configuration?.store }

    var minimumAge: Int {
        return self.locationDetails?.agePolicy.minimumAge ?? self.configuration?.minimumAge ?? 1
    }

    var ageVerificationState: String {
        return self.locationDetails?.agePolicy.approvalState(businessId: BusinessConfig.businessId)
            ?? "UNKNOWN:\(BusinessConfig.businessId)"
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
        self.ageVerificationTask?.cancel()
        self.acceptAgeTask?.cancel()
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
        cancelAgeEvaluation()
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
            try validate(configuration: configuration)

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
                    self.error = error
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
        cancelAgeEvaluation()
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
        cancelAgeEvaluation()
        self.selectLocationTask = nil
        self.selectionId = nil
        self.locationDetails = nil
        self.error = nil
        self.tabBarNavigationService.resetPathItems()
        self.state = .locations

    }

    func approveAgeVerification() async throws {

        try Task.checkCancellation()

        guard self.state == .ageVerification,
              let details = self.locationDetails else { return }

        let policy = details.agePolicy
        guard policy.isValid, policy.required else { throw StoreSessionError.invalidAgePolicy }

        cancelAgeEvaluation()

        let evaluationId = UUID()
        let locationId = details.location.id
        let userId = self.authService.currentUser?.id ?? self.userDefaultsService.guestIdentityId
        let isAuthenticated = self.authService.currentUser != nil
        let apiService = self.apiService

        self.ageEvaluationId = evaluationId

        defer {

            if self.ageEvaluationId == evaluationId {
                self.acceptAgeTask = nil
            }

        }

        if isAuthenticated {

            let acceptanceTask = Task {

                try Task.checkCancellation()
                return try await apiService.acceptCustomerAgeGate(locationId: locationId, policy: policy)

            }
            self.acceptAgeTask = acceptanceTask

            let acceptance: AgeGateAcceptance

            do {

                acceptance = try await withTaskCancellationHandler {
                    try await acceptanceTask.value
                } onCancel: {
                    acceptanceTask.cancel()
                }

            } catch {

                guard !Task.isCancelled,
                      self.ageEvaluationId == evaluationId,
                      self.authService.currentUser?.id == userId,
                      self.locationDetails?.location.id == locationId,
                      self.locationDetails?.agePolicy == policy else { throw CancellationError() }

                if case APIError.serverError(let statusCode, _) = error, statusCode == 409 {
                    await bootstrap()
                }

                throw error

            }
            try Task.checkCancellation()

            guard self.ageEvaluationId == evaluationId,
                  self.authService.currentUser?.id == userId,
                  self.locationDetails?.location.id == locationId,
                  self.locationDetails?.agePolicy == policy else { throw CancellationError() }
            guard acceptance.applies(to: policy, businessId: BusinessConfig.businessId, customerAccountId: userId) else {
                throw StoreSessionError.invalidAgePolicy
            }

        }

        try Task.checkCancellation()
        guard self.ageEvaluationId == evaluationId else { throw CancellationError() }

        self.userDefaultsService.approveAge(
            userId: userId,
            state: policy.approvalState(businessId: BusinessConfig.businessId),
            policy: policy
        )
        enterStore(locationId: locationId)

    }

    private func validate(configuration: CustomerBootstrap) throws {

        guard configuration.appKey.lowercased() == BusinessConfig.appKey.lowercased(),
              configuration.storeId.lowercased() == BusinessConfig.businessId.lowercased(),
              configuration.store.id.lowercased() == configuration.storeId.lowercased() else {
            throw StoreSessionError.invalidConfiguration
        }

    }

    private func validate(details: CustomerLocationDetails, locationId: String) throws {

        guard details.location.id.lowercased() == locationId.lowercased(),
              details.location.storeId.lowercased() == BusinessConfig.businessId.lowercased(),
              details.location.isAvailable,
              self.locations.contains(where: { $0.id.lowercased() == locationId.lowercased() }) else {
            throw StoreSessionError.invalidLocation
        }

        let policy = details.agePolicy
        guard policy.isValid,
              policy.canonicalCountryCode == normalizedScope(details.location.countryCode),
              policy.canonicalRegion == normalizedScope(details.location.region),
              self.configuration?.ageGateRequired != true ||
                (policy.required && policy.minimumAge >= (self.configuration?.minimumAge ?? 1)) else {
            throw StoreSessionError.invalidAgePolicy
        }

    }

    private func normalizedScope(_ value: String?) -> String? {

        let scope = value?.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        return scope?.isEmpty == false ? scope : nil

    }

    private func evaluateAgeVerification() {

        cancelAgeEvaluation()

        guard let details = self.locationDetails else { return }
        guard self.configuration?.state == .available else { return }

        let locationId = details.location.id
        let policy = details.agePolicy
        guard policy.isValid else {

            self.error = StoreSessionError.invalidAgePolicy
            self.state = .failed
            return

        }

        self.userDefaultsService.set(lastSelectedLocationId: locationId)
        self.error = nil

        guard policy.required else {

            enterStore(locationId: locationId)
            return

        }

        guard let userId = self.authService.currentUser?.id else {

            let isApproved = self.userDefaultsService.hasApprovedAge(
                userId: self.userDefaultsService.guestIdentityId,
                state: policy.approvalState(businessId: BusinessConfig.businessId),
                policy: policy
            )

            if isApproved {
                enterStore(locationId: locationId)
            } else {
                self.state = .ageVerification
            }

            return

        }

        let evaluationId = UUID()
        let apiService = self.apiService
        let businessId = BusinessConfig.businessId

        self.ageEvaluationId = evaluationId
        self.state = .loading

        self.ageVerificationTask = Task { [weak self] in

            defer {

                if self?.ageEvaluationId == evaluationId {
                    self?.ageVerificationTask = nil
                }

            }

            do {

                let acceptance = try await apiService.getCustomerAgeGateAcceptance(locationId: locationId)
                guard !Task.isCancelled,
                      self?.ageEvaluationId == evaluationId,
                      self?.authService.currentUser?.id == userId,
                      self?.locationDetails?.location.id == locationId,
                      self?.locationDetails?.agePolicy == policy else { return }

                guard acceptance?.applies(to: policy, businessId: businessId, customerAccountId: userId) == true else {

                    self?.state = .ageVerification
                    return

                }

                self?.userDefaultsService.approveAge(
                    userId: userId,
                    state: policy.approvalState(businessId: businessId),
                    policy: policy
                )
                self?.enterStore(locationId: locationId)

            } catch {

                guard !Task.isCancelled, self?.ageEvaluationId == evaluationId else { return }
                self?.error = error
                self?.state = .ageVerification

            }

        }

    }

    private func enterStore(locationId: String) {

        self.error = nil
        self.tabBarNavigationService.initializeStoreExperience(locationId: locationId)
        self.state = .store

    }

    private func cancelAgeEvaluation() {

        self.ageVerificationTask?.cancel()
        self.ageVerificationTask = nil
        self.acceptAgeTask?.cancel()
        self.acceptAgeTask = nil
        self.ageEvaluationId = nil

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

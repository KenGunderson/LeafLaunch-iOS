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
    private var acceptAgeTask: Task<Void, Never>?
    private var ageEvaluationId: UUID?
    private var isBootstrapping: Bool = false
    private var bootstrapId: UUID?
    private var pendingLocationDetails: CustomerLocationDetails?
    private var activeStoreIdentity: String?
    private var locationSelectionReturnIdentity: String?

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

    var canDismissLocationSelection: Bool {

        guard self.locationDetails != nil,
              let returnIdentity = self.locationSelectionReturnIdentity,
              returnIdentity == self.activeStoreIdentity else { return false }
        return returnIdentity == (self.authService.currentUser?.id ?? self.userDefaultsService.guestIdentityId)

    }

    var ageVerificationLocationId: String? {
        return self.ageVerificationDetails?.location.id
    }

    var ageVerificationDetails: CustomerLocationDetails? {
        return self.pendingLocationDetails ?? self.locationDetails
    }

    var minimumAge: Int {
        return self.ageVerificationDetails?.agePolicy.minimumAge ?? self.configuration?.minimumAge ?? 1
    }

    var ageVerificationState: String {
        return self.ageVerificationDetails?.agePolicy.approvalState(businessId: BusinessConfig.businessId)
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
        self.locationSelectionReturnIdentity = nil

        guard BusinessConfig.isConfigured else {

            self.state = .configurationRequired
            return

        }

        let isChoosingLocation = self.state == .locations ||
            self.state == .ageVerification ||
            self.selectLocationTask != nil ||
            (self.selectionId != nil && self.pendingLocationDetails != nil)
        let bootstrapId = UUID()
        self.bootstrapId = bootstrapId
        self.isBootstrapping = true
        cancelAgeEvaluation()
        self.selectLocationTask?.cancel()
        self.selectLocationTask = nil
        self.selectionId = nil
        self.error = nil
        self.pendingLocationDetails = nil
        self.state = .loading
        bindSubscribers()

        defer { self.isBootstrapping = false }

        do {

            let configuration = try await self.apiService.getCustomerBootstrap(appKey: BusinessConfig.appKey)
            guard !Task.isCancelled, self.bootstrapId == bootstrapId else { return }
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

            if isChoosingLocation {

                self.state = .locations
                return

            }

            if let locationId = self.userDefaultsService.lastSelectedLocationId {

                do {

                    let details = try await self.apiService.getCustomerLocation(
                        businessId: BusinessConfig.businessId,
                        locationId: locationId
                    )
                    guard !Task.isCancelled, self.bootstrapId == bootstrapId else { return }
                    try validate(details: details, locationId: locationId)

                    self.pendingLocationDetails = details
                    evaluateAgeVerification()

                } catch {

                    guard !Task.isCancelled, self.bootstrapId == bootstrapId else { return }

                    if self.locationDetails == nil {
                        self.userDefaultsService.set(lastSelectedLocationId: nil)
                    }

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
                    guard !Task.isCancelled, self.bootstrapId == bootstrapId else { return }
                    try validate(details: details, locationId: location.id)

                    self.pendingLocationDetails = details
                    evaluateAgeVerification()

                } catch {

                    guard !Task.isCancelled, self.bootstrapId == bootstrapId else { return }
                    self.error = error
                    self.state = .locations

                }

            } else {
                self.state = .locations
            }

        } catch {

            guard !Task.isCancelled, self.bootstrapId == bootstrapId else { return }
            self.error = error
            self.state = .failed

        }

    }

    func selectLocation(id: String) {

        guard self.locations.contains(where: { $0.id.lowercased() == id.lowercased() }) else { return }

        self.bootstrapId = nil
        self.selectLocationTask?.cancel()
        cancelAgeEvaluation()
        let selectionId = UUID()
        let apiService = self.apiService
        let businessId = BusinessConfig.businessId

        self.selectionId = selectionId
        self.error = nil
        self.pendingLocationDetails = nil
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

                self?.pendingLocationDetails = details
                self?.evaluateAgeVerification(allowsAgePresentation: true)

            } catch {

                guard !Task.isCancelled, self?.selectionId == selectionId else { return }
                self?.error = error
                self?.state = .locations

            }

        }

    }

    func showLocations() {

        let allowsDismissal = (self.state == .store && self.locationDetails != nil) || self.canDismissLocationSelection
        showLocations(allowsDismissal: allowsDismissal)

    }

    func cancelLocationSelection() {

        guard self.state == .locations, self.canDismissLocationSelection else { return }

        self.bootstrapId = nil
        self.selectLocationTask?.cancel()
        cancelAgeEvaluation()
        self.selectLocationTask = nil
        self.selectionId = nil
        self.pendingLocationDetails = nil
        self.error = nil
        self.locationSelectionReturnIdentity = nil
        self.state = .store

    }

    private func showLocations(allowsDismissal: Bool) {

        self.locationSelectionReturnIdentity = allowsDismissal
            ? (self.authService.currentUser?.id ?? self.userDefaultsService.guestIdentityId)
            : nil

        self.bootstrapId = nil

        self.selectLocationTask?.cancel()
        cancelAgeEvaluation()
        self.selectLocationTask = nil
        self.selectionId = nil
        self.pendingLocationDetails = nil
        self.error = nil
        self.state = .locations

    }

    func approveAgeVerification() throws {

        guard self.state == .ageVerification,
              let details = self.ageVerificationDetails else { return }

        let policy = details.agePolicy
        guard policy.isValid, policy.required else { throw StoreSessionError.invalidAgePolicy }

        cancelAgeEvaluation()

        let locationId = details.location.id
        let userId = self.authService.currentUser?.id ?? self.userDefaultsService.guestIdentityId

        self.userDefaultsService.approveAge(
            userId: userId,
            state: policy.approvalState(businessId: BusinessConfig.businessId),
            policy: policy
        )

        if self.authService.currentUser != nil {
            recordAgeAcceptance(locationId: locationId, userId: userId, policy: policy)
        }

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

    private func evaluateAgeVerification(allowsAgePresentation: Bool = false) {

        cancelAgeEvaluation()

        guard let details = self.ageVerificationDetails else { return }
        guard self.configuration?.state == .available else { return }

        let locationId = details.location.id
        let policy = details.agePolicy
        guard policy.isValid else {

            self.error = StoreSessionError.invalidAgePolicy
            self.state = .failed
            return

        }

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
                requireAgeVerification(allowsPresentation: allowsAgePresentation)
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
                      self?.ageVerificationDetails?.location.id == locationId,
                      self?.ageVerificationDetails?.agePolicy == policy else { return }

                guard acceptance?.applies(to: policy, businessId: businessId, customerAccountId: userId) == true else {

                    self?.requireAgeVerification(allowsPresentation: allowsAgePresentation)
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
                self?.requireAgeVerification(allowsPresentation: allowsAgePresentation)

            }

        }

    }

    private func requireAgeVerification(allowsPresentation: Bool) {

        if allowsPresentation {
            self.state = .ageVerification
        } else {
            showLocations(allowsDismissal: false)
        }

    }

    private func enterStore(locationId: String) {

        guard let details = self.ageVerificationDetails,
              details.location.id == locationId else { return }

        self.locationDetails = details
        self.activeStoreIdentity = self.authService.currentUser?.id ?? self.userDefaultsService.guestIdentityId
        self.pendingLocationDetails = nil
        self.locationSelectionReturnIdentity = nil
        self.userDefaultsService.set(lastSelectedLocationId: locationId)
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

                guard let self, !self.isBootstrapping else { return }

                if self.state == .locations {

                    if self.locationSelectionReturnIdentity != nil && !self.canDismissLocationSelection {

                        self.locationSelectionReturnIdentity = nil
                        self.state = .locations

                    }

                    return

                }

                guard self.state == .store || self.state == .ageVerification || self.state == .loading,
                      self.selectLocationTask == nil || self.pendingLocationDetails != nil else { return }
                self.evaluateAgeVerification()

            }

    }

}

extension StoreSessionService {

    private func recordAgeAcceptance(locationId: String,
                                     userId: String,
                                     policy: EffectiveAgePolicy) {

        let evaluationId = UUID()
        let apiService = self.apiService
        let authService = self.authService
        let businessId = BusinessConfig.businessId

        self.ageEvaluationId = evaluationId

        // The session owns this request so dismissing the sheet cannot cancel it.
        self.acceptAgeTask = Task { [weak self] in

            defer {

                if self?.ageEvaluationId == evaluationId {
                    self?.acceptAgeTask = nil
                }

            }

            do {

                guard !Task.isCancelled,
                      authService.currentUser?.id == userId else { return }

                let acceptance = try await apiService.acceptCustomerAgeGate(locationId: locationId, policy: policy)
                guard !Task.isCancelled,
                      self?.ageEvaluationId == evaluationId,
                      authService.currentUser?.id == userId,
                      self?.locationDetails?.location.id == locationId,
                      self?.locationDetails?.agePolicy == policy else { return }

                guard acceptance.applies(to: policy, businessId: businessId, customerAccountId: userId) else {
                    throw StoreSessionError.invalidAgePolicy
                }

            } catch {

                guard !Task.isCancelled,
                      !(error is CancellationError),
                      self?.ageEvaluationId == evaluationId,
                      authService.currentUser?.id == userId,
                      self?.locationDetails?.location.id == locationId,
                      self?.locationDetails?.agePolicy == policy else { return }

                self?.logError(
                    title: "Age Acceptance Error",
                    message: error.getMessageForError()
                )

                if case APIError.serverError(let statusCode, _) = error, statusCode == 409 {

                    // Bootstrap cancels outstanding acceptance work; this request has already finished.
                    self?.acceptAgeTask = nil
                    await self?.bootstrap()

                }

            }

        }

    }

}

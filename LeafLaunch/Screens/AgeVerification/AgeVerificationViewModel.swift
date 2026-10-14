import SwiftUI

@MainActor
final class AgeVerificationViewModel: ViewModel {

    let loggerName: String = "AGE_VERIFICATION_VIEW_MODEL"
    let loggerEmoji: String = "🔞"

    private let storeSessionService: StoreSessionServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let alertService: AlertServiceProtocol

    private var locationId: String?
    private var approveAgeTask: Task<Void, Never>?
    private var approvalId: UUID?

    @Published private(set) var isApproving: Bool = false

    var minimumAge: Int { self.storeSessionService.minimumAge }
    var stateName: String { self.storeSessionService.ageVerificationState }

    init(storeSessionService: StoreSessionServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         alertService: AlertServiceProtocol) {
        self.storeSessionService = storeSessionService
        self.analyticsService = analyticsService
        self.alertService = alertService

        logInit()

    }

    isolated deinit {

        self.approveAgeTask?.cancel()
        logDeinit()

    }

    @discardableResult
    func setup(locationId: String) -> Self {

        if self.locationId != locationId {

            self.approveAgeTask?.cancel()
            self.approveAgeTask = nil
            self.approvalId = nil
            self.isApproving = false

        }

        self.locationId = locationId
        return self

    }

    func handleFirstAppear() {
        track()
    }

    func approve() {

        guard self.approveAgeTask == nil,
              self.storeSessionService.locationDetails?.location.id == self.locationId else { return }

        let storeSessionService = self.storeSessionService
        let alertService = self.alertService
        let approvalId = UUID()

        self.approvalId = approvalId
        self.isApproving = true

        self.approveAgeTask = Task { [weak self] in

            guard !Task.isCancelled else { return }

            let loadingIndicator = RuneAlert(.simpleLoadingIndicator)
            alertService.showAlert(loadingIndicator)

            defer {

                if self?.approvalId == approvalId {

                    self?.isApproving = false
                    self?.approveAgeTask = nil

                }

                alertService.dismissAlert(loadingIndicator)

            }

            do {

                try await storeSessionService.approveAgeVerification()
                guard !Task.isCancelled, self?.approvalId == approvalId else { return }

            } catch {

                guard !Task.isCancelled,
                      !(error is CancellationError),
                      self?.approvalId == approvalId else { return }
                self?.presentApprovalError()

            }

        }

    }

    private func presentApprovalError() {

        self.alertService.showAlert(.init(
            .appAlert(
                .error(
                    message: Constants.Message.errorMessage("age verification"),
                    action: {}
                )
            )
        ))

    }

}

extension AgeVerificationViewModel {

    func track() {

        guard let locationId = self.locationId else { return }
        self.analyticsService.track(screen: .customer(.ageVerification(locationId: locationId)))

    }

}

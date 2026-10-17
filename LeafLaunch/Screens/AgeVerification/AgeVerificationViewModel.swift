import SwiftUI

@MainActor
final class AgeVerificationViewModel: ViewModel {

    let loggerName: String = "AGE_VERIFICATION_VIEW_MODEL"
    let loggerEmoji: String = "🔞"

    private let storeSessionService: StoreSessionServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let alertService: AlertServiceProtocol

    private var locationId: String?

    @Published private(set) var isApproving: Bool = false

    var configuration: CustomerBootstrap? { self.storeSessionService.configuration }
    var minimumAge: Int { self.storeSessionService.minimumAge }

    var locationDetails: CustomerLocationDetails? {

        guard let details = self.storeSessionService.ageVerificationDetails,
              details.location.id == self.locationId else { return nil }
        return details

    }

    init(storeSessionService: StoreSessionServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         alertService: AlertServiceProtocol) {
        self.storeSessionService = storeSessionService
        self.analyticsService = analyticsService
        self.alertService = alertService

        logInit()

    }

    isolated deinit {

        logDeinit()

    }

    @discardableResult
    func setup(locationId: String) -> Self {

        self.isApproving = false

        self.locationId = locationId
        return self

    }

    func handleFirstAppear() {
        track()
    }

    func approve() {

        guard !self.isApproving,
              self.storeSessionService.state == .ageVerification,
              self.storeSessionService.ageVerificationLocationId == self.locationId else { return }

        self.isApproving = true

        do {
            try self.storeSessionService.approveAgeVerification()
        } catch {

            self.isApproving = false
            presentApprovalError()

        }

    }

    private func presentApprovalError() {

        self.alertService.showAlert(.init(
            .appAlert(
                .error(
                    message: Constants.Message.ageVerificationErrorMessage,
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

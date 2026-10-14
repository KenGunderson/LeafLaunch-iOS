import SwiftUI

@MainActor
final class AgeVerificationViewModel: ViewModel {

    let loggerName: String = "AGE_VERIFICATION_VIEW_MODEL"
    let loggerEmoji: String = "🔞"

    private let storeSessionService: StoreSessionServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol

    private var locationId: String?

    var minimumAge: Int { self.storeSessionService.minimumAge }
    var stateName: String { self.storeSessionService.ageVerificationState }

    init(storeSessionService: StoreSessionServiceProtocol,
         analyticsService: AnalyticsServiceProtocol) {
        self.storeSessionService = storeSessionService
        self.analyticsService = analyticsService

        logInit()

    }

    isolated deinit {
        logDeinit()
    }

    @discardableResult
    func setup(locationId: String) -> Self {

        self.locationId = locationId
        return self

    }

    func handleFirstAppear() {
        track()
    }

    func approve() {
        self.storeSessionService.approveAgeVerification()
    }

}

extension AgeVerificationViewModel {

    func track() {

        guard let locationId = self.locationId else { return }
        self.analyticsService.track(screen: .customer(.ageVerification(locationId: locationId)))

    }

}

import SwiftUI

@MainActor
final class EventDetailsViewModel: ViewModel {

    let loggerName: String = "EVENT_DETAILS_VIEW_MODEL"
    let loggerEmoji: String = ""

    private let storeSessionService: StoreSessionServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol

    private weak var navigationService: NavigationService?
    private var locationId: String?

    @Published private(set) var event: StoreEvent?

    var locationDetails: CustomerLocationDetails? {

        guard let details = self.storeSessionService.locationDetails,
              details.location.id == self.locationId else { return nil }
        return details

    }

    var schedule: StoreEventSchedule? {

        guard let event = self.event else { return nil }
        return StoreEventSchedule(event: event, location: self.locationDetails?.location)

    }

    var directionsURL: URL? {

        guard let address = self.locationDetails?.address, !address.isEmpty else { return nil }

        var components = URLComponents(string: "https://maps.apple.com/")
        components?.queryItems = [URLQueryItem(name: "q", value: address)]
        return components?.url

    }

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
    func setup(locationId: String, event: StoreEvent) -> Self {

        self.locationId = locationId
        self.event = event
        return self

    }

    func setup(navigationService: NavigationService) {
        self.navigationService = navigationService
    }

    func handleFirstAppear() {
        track()
    }

    func dismiss() {
        self.navigationService?.pop()
    }

}

extension EventDetailsViewModel {

    func track() {

        guard let locationId = self.locationId,
              let event = self.event else { return }
        self.analyticsService.track(screen: .customer(.event(locationId: locationId, eventId: event.id)))

    }

}

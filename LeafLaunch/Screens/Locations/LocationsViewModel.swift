import Combine
import SwiftUI

@MainActor
final class LocationsViewModel: ViewModel {

    let loggerName: String = "LOCATIONS_VIEW_MODEL"
    let loggerEmoji: String = "📍"

    private let storeSessionService: StoreSessionServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let alertService: AlertServiceProtocol

    private weak var navigationService: NavigationService?
    private var sessionSubscription: AnyCancellable?
    private var loadingIndicator: RuneAlert?
    private var lastPresentedErrorMessage: String?

    @Published private(set) var locations: [BootstrapLocation] = []

    var businessName: String {
        return self.storeSessionService.configuration?.publicName ?? String(localized: "Locations")
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

        self.sessionSubscription?.cancel()

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

import SwiftUI

@MainActor
final class StoreContainerViewModel: ViewModel {

    let loggerName: String = "STORE_CONTAINER_VIEW_MODEL"
    let loggerEmoji: String = "🏪"

    private let storeSessionService: StoreSessionServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol

    let tabBarNavigationService: TabBarNavigationService
    let detailsViewModel: StoreDetailsViewModel
    let productListViewModel: ProductListViewModel
    let accountDetailsViewModel: AccountDetailsViewModel

    private(set) var locationId: String?

    init(storeSessionService: StoreSessionServiceProtocol,
         tabBarNavigationService: TabBarNavigationService,
         analyticsService: AnalyticsServiceProtocol,
         detailsViewModel: StoreDetailsViewModel,
         productListViewModel: ProductListViewModel,
         accountDetailsViewModel: AccountDetailsViewModel) {

        self.storeSessionService = storeSessionService
        self.tabBarNavigationService = tabBarNavigationService
        self.analyticsService = analyticsService
        self.detailsViewModel = detailsViewModel
        self.productListViewModel = productListViewModel
        self.accountDetailsViewModel = accountDetailsViewModel

        logInit()

    }

    isolated deinit {
        logDeinit()
    }

    @discardableResult
    func setup(locationId: String) -> Self {

        self.locationId = locationId
        self.detailsViewModel.setup(locationId: locationId)
        self.productListViewModel.setup(locationId: locationId)
        self.accountDetailsViewModel.setup(locationId: locationId)
        return self

    }

    func handleFirstAppear() {

        track()

        guard let locationId = self.locationId,
              self.storeSessionService.state == .store else { return }
        self.tabBarNavigationService.initializeStoreExperience(locationId: locationId)

    }

}

extension StoreContainerViewModel {

    func track() {

        guard let locationId = self.locationId else { return }
        self.analyticsService.track(screen: .customer(.store(locationId: locationId)))

    }

}

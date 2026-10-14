import SwiftUI

@MainActor
final class StoreDetailsViewModel: ViewModel {

    let loggerName: String = "STORE_DETAILS_VIEW_MODEL"
    let loggerEmoji: String = "🏪"

    private let storeSessionService: StoreSessionServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol

    let tabBarNavigationService: TabBarNavigationService
    let overviewViewModel: StoreOverviewViewModel
    let shopViewModel: StoreShopViewModel
    let favoritesViewModel: StoreFavoritesViewModel
    let accountViewModel: StoreAccountViewModel

    private(set) var locationId: String?

    init(storeSessionService: StoreSessionServiceProtocol,
         tabBarNavigationService: TabBarNavigationService,
         analyticsService: AnalyticsServiceProtocol,
         overviewViewModel: StoreOverviewViewModel,
         shopViewModel: StoreShopViewModel,
         favoritesViewModel: StoreFavoritesViewModel,
         accountViewModel: StoreAccountViewModel) {
        
        self.storeSessionService = storeSessionService
        self.tabBarNavigationService = tabBarNavigationService
        self.analyticsService = analyticsService
        self.overviewViewModel = overviewViewModel
        self.shopViewModel = shopViewModel
        self.favoritesViewModel = favoritesViewModel
        self.accountViewModel = accountViewModel

        logInit()

    }

    isolated deinit {
        logDeinit()
    }

    @discardableResult
    func setup(locationId: String) -> Self {

        self.locationId = locationId
        self.overviewViewModel.setup(locationId: locationId)
        self.shopViewModel.setup(locationId: locationId)
        self.favoritesViewModel.setup(locationId: locationId)
        self.accountViewModel.setup(locationId: locationId)
        return self

    }

    func handleFirstAppear() {

        track()

        guard let locationId = self.locationId,
              self.storeSessionService.state == .store else { return }
        self.tabBarNavigationService.initializeStoreExperience(locationId: locationId)

    }

}

extension StoreDetailsViewModel {

    func track() {

        guard let locationId = self.locationId else { return }
        self.analyticsService.track(screen: .customer(.store(locationId: locationId)))

    }

}

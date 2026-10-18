import FactoryKit

extension Container {

    @MainActor
    var locationListViewModel: Factory<LocationListViewModel> {

        self { @MainActor in
            LocationListViewModel(
                storeSessionService: self.storeSessionService(),
                apiService: self.apiService(),
                analyticsService: self.analyticsService(),
                alertService: self.alertService()
            )
        }

    }

    @MainActor
    var storeContainerViewModel: Factory<StoreContainerViewModel> {

        self { @MainActor in
            StoreContainerViewModel(
                storeSessionService: self.storeSessionService(),
                tabBarNavigationService: self.tabBarNavigationService(),
                analyticsService: self.analyticsService(),
                detailsViewModel: self.storeDetailsViewModel(),
                productListViewModel: self.productListViewModel(),
                accountDetailsViewModel: self.accountDetailsViewModel()
            )
        }

    }

    @MainActor
    var storeDetailsViewModel: Factory<StoreDetailsViewModel> {

        self { @MainActor in
            StoreDetailsViewModel(
                apiService: self.apiService(),
                storeSessionService: self.storeSessionService(),
                userDefaultsService: self.userDefaultsService(),
                analyticsService: self.analyticsService(),
                alertService: self.alertService()
            )
        }

    }

    @MainActor
    var eventListViewModel: Factory<EventListViewModel> {

        self { @MainActor in
            EventListViewModel(
                apiService: self.apiService(),
                storeSessionService: self.storeSessionService(),
                analyticsService: self.analyticsService(),
                alertService: self.alertService()
            )
        }

    }

    @MainActor
    var eventDetailsViewModel: Factory<EventDetailsViewModel> {

        self { @MainActor in
            EventDetailsViewModel(
                storeSessionService: self.storeSessionService(),
                analyticsService: self.analyticsService()
            )
        }

    }

    @MainActor
    var promotionProductListViewModel: Factory<PromotionProductListViewModel> {

        self { @MainActor in
            PromotionProductListViewModel(
                analyticsService: self.analyticsService(),
                alertService: self.alertService()
            )
        }

    }

    @MainActor
    var productListViewModel: Factory<ProductListViewModel> {

        self { @MainActor in
            ProductListViewModel(
                apiService: self.apiService(),
                storeSessionService: self.storeSessionService(),
                userDefaultsService: self.userDefaultsService(),
                analyticsService: self.analyticsService(),
                alertService: self.alertService()
            )
        }

    }

    @MainActor
    var favoriteProductListViewModel: Factory<FavoriteProductListViewModel> {

        self { @MainActor in
            FavoriteProductListViewModel(
                apiService: self.apiService(),
                userDefaultsService: self.userDefaultsService(),
                tabBarNavigationService: self.tabBarNavigationService(),
                analyticsService: self.analyticsService(),
                alertService: self.alertService()
            )
        }

    }

    @MainActor
    var productDetailsViewModel: Factory<ProductDetailsViewModel> {

        self { @MainActor in
            ProductDetailsViewModel(
                apiService: self.apiService(),
                storeSessionService: self.storeSessionService(),
                userDefaultsService: self.userDefaultsService(),
                analyticsService: self.analyticsService(),
                alertService: self.alertService()
            )
        }

    }

    @MainActor
    var accountDetailsViewModel: Factory<AccountDetailsViewModel> {

        self { @MainActor in
            AccountDetailsViewModel(
                apiService: self.apiService(),
                authService: self.authService(),
                storeSessionService: self.storeSessionService(),
                analyticsService: self.analyticsService(),
                alertService: self.alertService()
            )
        }

    }

    @MainActor
    var loyaltyHistoryListViewModel: Factory<LoyaltyHistoryListViewModel> {

        self { @MainActor in
            LoyaltyHistoryListViewModel(
                apiService: self.apiService(),
                authService: self.authService(),
                analyticsService: self.analyticsService(),
                alertService: self.alertService()
            )
        }

    }

}

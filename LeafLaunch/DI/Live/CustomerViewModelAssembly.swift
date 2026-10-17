import FactoryKit

extension Container {

    @MainActor
    var locationsViewModel: Factory<LocationsViewModel> {

        self { @MainActor in
            LocationsViewModel(
                storeSessionService: self.storeSessionService(),
                apiService: self.apiService(),
                analyticsService: self.analyticsService(),
                alertService: self.alertService()
            )
        }

    }

    @MainActor
    var ageVerificationViewModel: Factory<AgeVerificationViewModel> {

        self { @MainActor in
            AgeVerificationViewModel(
                storeSessionService: self.storeSessionService(),
                analyticsService: self.analyticsService(),
                alertService: self.alertService()
            )
        }

    }

    @MainActor
    var storeDetailsViewModel: Factory<StoreDetailsViewModel> {

        self { @MainActor in
            StoreDetailsViewModel(
                storeSessionService: self.storeSessionService(),
                tabBarNavigationService: self.tabBarNavigationService(),
                analyticsService: self.analyticsService(),
                overviewViewModel: self.storeOverviewViewModel(),
                shopViewModel: self.storeShopViewModel(),
                accountViewModel: self.storeAccountViewModel()
            )
        }

    }

    @MainActor
    var storeOverviewViewModel: Factory<StoreOverviewViewModel> {

        self { @MainActor in
            StoreOverviewViewModel(
                apiService: self.apiService(),
                storeSessionService: self.storeSessionService(),
                userDefaultsService: self.userDefaultsService(),
                analyticsService: self.analyticsService(),
                alertService: self.alertService()
            )
        }

    }

    @MainActor
    var storeEventsViewModel: Factory<StoreEventsViewModel> {

        self { @MainActor in
            StoreEventsViewModel(
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
    var storeShopViewModel: Factory<StoreShopViewModel> {

        self { @MainActor in
            StoreShopViewModel(
                apiService: self.apiService(),
                userDefaultsService: self.userDefaultsService(),
                analyticsService: self.analyticsService(),
                alertService: self.alertService()
            )
        }

    }

    @MainActor
    var favoriteProductsViewModel: Factory<FavoriteProductsViewModel> {

        self { @MainActor in
            FavoriteProductsViewModel(
                apiService: self.apiService(),
                userDefaultsService: self.userDefaultsService(),
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
    var storeAccountViewModel: Factory<StoreAccountViewModel> {

        self { @MainActor in
            StoreAccountViewModel(
                apiService: self.apiService(),
                authService: self.authService(),
                analyticsService: self.analyticsService(),
                alertService: self.alertService()
            )
        }

    }

}

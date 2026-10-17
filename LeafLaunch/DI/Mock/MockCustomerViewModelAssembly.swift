import FactoryKit

final class MockCustomerViewModelAssembly {

    @MainActor
    func assemble(container: Container) {

        container.locationsViewModel.register { @MainActor in
            LocationsViewModel(
                storeSessionService: container.storeSessionService(),
                apiService: container.apiService(),
                analyticsService: container.analyticsService(),
                alertService: container.alertService()
            )
        }

        container.ageVerificationViewModel.register { @MainActor in
            AgeVerificationViewModel(
                storeSessionService: container.storeSessionService(),
                analyticsService: container.analyticsService(),
                alertService: container.alertService()
            )
        }

        container.storeDetailsViewModel.register { @MainActor in
            StoreDetailsViewModel(
                storeSessionService: container.storeSessionService(),
                tabBarNavigationService: container.tabBarNavigationService(),
                analyticsService: container.analyticsService(),
                overviewViewModel: container.storeOverviewViewModel(),
                shopViewModel: container.storeShopViewModel(),
                accountViewModel: container.storeAccountViewModel()
            )
        }

        container.storeOverviewViewModel.register { @MainActor in
            StoreOverviewViewModel(
                apiService: container.apiService(),
                storeSessionService: container.storeSessionService(),
                userDefaultsService: container.userDefaultsService(),
                analyticsService: container.analyticsService(),
                alertService: container.alertService()
            )
        }

        container.storeEventsViewModel.register { @MainActor in
            StoreEventsViewModel(
                apiService: container.apiService(),
                storeSessionService: container.storeSessionService(),
                analyticsService: container.analyticsService(),
                alertService: container.alertService()
            )
        }

        container.eventDetailsViewModel.register { @MainActor in
            EventDetailsViewModel(
                storeSessionService: container.storeSessionService(),
                analyticsService: container.analyticsService()
            )
        }

        container.storeShopViewModel.register { @MainActor in
            StoreShopViewModel(
                apiService: container.apiService(),
                userDefaultsService: container.userDefaultsService(),
                analyticsService: container.analyticsService(),
                alertService: container.alertService()
            )
        }

        container.favoriteProductsViewModel.register { @MainActor in
            FavoriteProductsViewModel(
                apiService: container.apiService(),
                userDefaultsService: container.userDefaultsService(),
                analyticsService: container.analyticsService(),
                alertService: container.alertService()
            )
        }

        container.productDetailsViewModel.register { @MainActor in
            ProductDetailsViewModel(
                apiService: container.apiService(),
                storeSessionService: container.storeSessionService(),
                userDefaultsService: container.userDefaultsService(),
                analyticsService: container.analyticsService(),
                alertService: container.alertService()
            )
        }

        container.storeAccountViewModel.register { @MainActor in
            StoreAccountViewModel(
                apiService: container.apiService(),
                authService: container.authService(),
                analyticsService: container.analyticsService(),
                alertService: container.alertService()
            )
        }

    }

}

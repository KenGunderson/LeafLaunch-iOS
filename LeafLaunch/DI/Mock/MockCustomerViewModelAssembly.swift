import FactoryKit

final class MockCustomerViewModelAssembly {

    @MainActor
    func assemble(container: Container) {

        container.locationsViewModel.register { @MainActor in
            LocationsViewModel(
                storeSessionService: container.storeSessionService(),
                analyticsService: container.analyticsService(),
                alertService: container.alertService()
            )
        }

        container.ageVerificationViewModel.register { @MainActor in
            AgeVerificationViewModel(
                storeSessionService: container.storeSessionService(),
                analyticsService: container.analyticsService()
            )
        }

        container.storeDetailsViewModel.register { @MainActor in
            StoreDetailsViewModel(
                storeSessionService: container.storeSessionService(),
                tabBarNavigationService: container.tabBarNavigationService(),
                analyticsService: container.analyticsService(),
                overviewViewModel: container.storeOverviewViewModel(),
                shopViewModel: container.storeShopViewModel(),
                favoritesViewModel: container.storeFavoritesViewModel(),
                accountViewModel: container.storeAccountViewModel()
            )
        }

        container.storeOverviewViewModel.register { @MainActor in
            StoreOverviewViewModel(
                apiService: container.apiService(),
                storeSessionService: container.storeSessionService(),
                analyticsService: container.analyticsService(),
                alertService: container.alertService()
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

        container.storeFavoritesViewModel.register { @MainActor in
            StoreFavoritesViewModel(
                apiService: container.apiService(),
                userDefaultsService: container.userDefaultsService(),
                analyticsService: container.analyticsService(),
                alertService: container.alertService()
            )
        }

        container.productDetailsViewModel.register { @MainActor in
            ProductDetailsViewModel(
                apiService: container.apiService(),
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

import FactoryKit

final class MockCustomerViewModelAssembly {

    @MainActor
    func assemble(container: Container) {

        container.locationListViewModel.register { @MainActor in
            LocationListViewModel(
                storeSessionService: container.storeSessionService(),
                apiService: container.apiService(),
                analyticsService: container.analyticsService(),
                alertService: container.alertService()
            )
        }

        container.storeContainerViewModel.register { @MainActor in
            StoreContainerViewModel(
                storeSessionService: container.storeSessionService(),
                tabBarNavigationService: container.tabBarNavigationService(),
                analyticsService: container.analyticsService(),
                detailsViewModel: container.storeDetailsViewModel(),
                productListViewModel: container.productListViewModel(),
                accountDetailsViewModel: container.accountDetailsViewModel()
            )
        }

        container.storeDetailsViewModel.register { @MainActor in
            StoreDetailsViewModel(
                apiService: container.apiService(),
                storeSessionService: container.storeSessionService(),
                userDefaultsService: container.userDefaultsService(),
                analyticsService: container.analyticsService(),
                alertService: container.alertService()
            )
        }

        container.eventListViewModel.register { @MainActor in
            EventListViewModel(
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

        container.promotionProductListViewModel.register { @MainActor in
            PromotionProductListViewModel(
                analyticsService: container.analyticsService(),
                alertService: container.alertService()
            )
        }

        container.productListViewModel.register { @MainActor in
            ProductListViewModel(
                apiService: container.apiService(),
                storeSessionService: container.storeSessionService(),
                userDefaultsService: container.userDefaultsService(),
                analyticsService: container.analyticsService(),
                alertService: container.alertService()
            )
        }

        container.favoriteProductListViewModel.register { @MainActor in
            FavoriteProductListViewModel(
                apiService: container.apiService(),
                userDefaultsService: container.userDefaultsService(),
                tabBarNavigationService: container.tabBarNavigationService(),
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

        container.accountDetailsViewModel.register { @MainActor in
            AccountDetailsViewModel(
                apiService: container.apiService(),
                authService: container.authService(),
                storeSessionService: container.storeSessionService(),
                analyticsService: container.analyticsService(),
                alertService: container.alertService()
            )
        }

        container.loyaltyHistoryListViewModel.register { @MainActor in
            LoyaltyHistoryListViewModel(
                apiService: container.apiService(),
                authService: container.authService(),
                analyticsService: container.analyticsService(),
                alertService: container.alertService()
            )
        }

    }

}

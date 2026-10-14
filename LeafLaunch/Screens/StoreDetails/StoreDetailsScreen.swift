import SwiftUI

struct StoreDetailsScreen: GPView {

    @Environment(\.style) private var style

    @StateObject private var viewModel: StoreDetailsViewModel

    init(viewModel: StoreDetailsViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {

        @Bindable var tabBarNavigationService = self.viewModel.tabBarNavigationService

        TabView(selection: $tabBarNavigationService.selectedTab) {

            AppRootView(navigationService: Bindable(tabBarNavigationService.tab1NavigationService)) {
                StoreOverviewScreen(viewModel: self.viewModel.overviewViewModel)
            }
            .tabItem { Text(Tab.tab1.title) }
            .tag(Tab.tab1)

            AppRootView(navigationService: Bindable(tabBarNavigationService.tab2NavigationService)) {
                StoreShopScreen(viewModel: self.viewModel.shopViewModel)
            }
            .tabItem { Text(Tab.tab2.title) }
            .tag(Tab.tab2)

            AppRootView(navigationService: Bindable(tabBarNavigationService.tab3NavigationService)) {
                StoreFavoritesScreen(viewModel: self.viewModel.favoritesViewModel)
            }
            .tabItem { Text(Tab.tab3.title) }
            .tag(Tab.tab3)

            AppRootView(navigationService: Bindable(tabBarNavigationService.tab4NavigationService)) {
                StoreAccountScreen(viewModel: self.viewModel.accountViewModel)
            }
            .tabItem { Text(Tab.tab4.title) }
            .tag(Tab.tab4)

        }
        .background(self.style.background(.primary))
        .tint(.init(.foreground(.primary)))
        .onFirstAppear { [weak viewModel] in viewModel?.handleFirstAppear() }

    }

}

#Preview {

    StoreDetailsScreen(
        viewModel: mockResolve(StoreDetailsViewModel.self)
            .setup(locationId: MockCustomerModels.primaryLocationId)
    )
    .withMockServices()

}

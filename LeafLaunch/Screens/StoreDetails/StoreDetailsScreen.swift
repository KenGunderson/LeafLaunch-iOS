import SwiftUI

struct StoreDetailsScreen: GPView {

    @Environment(\.style) private var style

    @StateObject private var viewModel: StoreDetailsViewModel

    init(viewModel: StoreDetailsViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {

        let navigation = Bindable(self.viewModel.tabBarNavigationService)

        ZStack {

            tabContent(selectedTab: navigation.selectedTab)

            TabBarScreen(
                selectedTab: Binding(
                    get: { self.viewModel.tabBarNavigationService.selectedTab },
                    set: { self.viewModel.tabBarNavigationService.select($0) }
                ),
                isTabBarVisible: navigation.isTabBarVisible
            )

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(self.style.background(.primary))
        .tint(self.style.palette(.link))
        .environment(self.viewModel.tabBarNavigationService)
        .onFirstAppear { [weak viewModel] in viewModel?.handleFirstAppear() }

    }

    @ViewBuilder
    private func tabContent(selectedTab: Binding<Tab>) -> some View {

        let tabBarNavigationService = self.viewModel.tabBarNavigationService

        TabView(selection: selectedTab) {

            ForEach(Tab.allCases, id: \.self) { tab in

                switch tab {
                case .tab1:

                    AppRootView(navigationService: Bindable(tabBarNavigationService.tab1NavigationService)) {
                        StoreOverviewScreen(viewModel: self.viewModel.overviewViewModel)
                    }
                    .tag(tab)

                case .tab2:

                    AppRootView(navigationService: Bindable(tabBarNavigationService.tab2NavigationService)) {
                        StoreShopScreen(viewModel: self.viewModel.shopViewModel)
                    }
                    .tag(tab)

                case .tab3:

                    AppRootView(navigationService: Bindable(tabBarNavigationService.tab3NavigationService)) {
                        StoreFavoritesScreen(viewModel: self.viewModel.favoritesViewModel)
                    }
                    .tag(tab)

                case .tab4:

                    AppRootView(navigationService: Bindable(tabBarNavigationService.tab4NavigationService)) {
                        StoreAccountScreen(viewModel: self.viewModel.accountViewModel)
                    }
                    .safeAreaInset(edge: .bottom, spacing: 0) {

                        if let route = tabBarNavigationService.tab4NavigationService.routes.last,
                           case .auth = route {

                            Color.clear
                                .frame(height: 0)
                                .tabFlowContentSpacing()

                        }

                    }
                    .tag(tab)

                }

            }

        }
        .toolbar(.hidden, for: .tabBar)
        .ignoresSafeArea(.container, edges: .bottom)

    }

}

#Preview {

    StoreDetailsScreen(
        viewModel: mockResolve(StoreDetailsViewModel.self)
            .setup(locationId: MockCustomerModels.primaryLocationId)
    )
    .withMockPreviews()

}

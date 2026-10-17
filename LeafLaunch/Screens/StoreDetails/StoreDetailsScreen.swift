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

        TabView(selection: selectedTab) {

            ForEach(Tab.allCases, id: \.self) { tab in

                tabRoot(tab)
                    .toolbarVisibility(.hidden, for: .tabBar)
                    .toolbarBackgroundVisibility(.hidden, for: .tabBar)
                    .tag(tab)

            }

        }
        .scrollEdgeEffectHidden(true, for: .bottom)
        .ignoresSafeArea(.container, edges: .bottom)

    }

    @ViewBuilder
    private func tabRoot(_ tab: Tab) -> some View {

        let tabBarNavigationService = self.viewModel.tabBarNavigationService

        switch tab {
        case .tab1:

            AppRootView(navigationService: Bindable(tabBarNavigationService.tab1NavigationService)) {
                StoreOverviewScreen(viewModel: self.viewModel.overviewViewModel)
            }

        case .tab2:

            AppRootView(navigationService: Bindable(tabBarNavigationService.tab2NavigationService)) {
                StoreShopScreen(viewModel: self.viewModel.shopViewModel)
            }

        case .tab3:

            AppRootView(navigationService: Bindable(tabBarNavigationService.tab3NavigationService)) {
                StoreAccountScreen(viewModel: self.viewModel.accountViewModel)
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {

                accountTabInset()

            }

        }

    }

    @ViewBuilder
    private func accountTabInset() -> some View {

        if let route = self.viewModel.tabBarNavigationService.tab3NavigationService.routes.last,
           case .auth = route {

            Color.clear
                .frame(height: 0)
                .tabFlowContentSpacing()

        }

    }

}

#Preview {

    StoreDetailsScreen(
        viewModel: mockResolve(StoreDetailsViewModel.self)
            .setup(locationId: MockCustomerModels.primaryLocationId)
    )
    .withMockPreviews()

}

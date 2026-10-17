//
//  MockAssembly.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 7/23/24.
//

import SwiftUI
import FactoryKit

@preconcurrency
class MockAppAssembler {

    static let shared = MockAppAssembler()

    let container: Container

    private init() {

        self.container = Container()

        MockServiceAssembly()
            .assemble(container: self.container)

        MockViewModelAssembly()
            .assemble(container: self.container)

        MockCustomerViewModelAssembly()
            .assemble(container: self.container)

    }

    func resolve<T>(_ type: T.Type) -> T {

        if type == LocationsViewModel.self {
            return self.container.locationsViewModel() as! T
        }

        if type == AgeVerificationViewModel.self {
            return self.container.ageVerificationViewModel() as! T
        }

        if type == StoreDetailsViewModel.self {
            return self.container.storeDetailsViewModel() as! T
        }

        if type == StoreOverviewViewModel.self {
            return self.container.storeOverviewViewModel() as! T
        }

        if type == StoreEventsViewModel.self {
            return self.container.storeEventsViewModel() as! T
        }

        if type == EventDetailsViewModel.self {
            return self.container.eventDetailsViewModel() as! T
        }

        if type == StoreShopViewModel.self {
            return self.container.storeShopViewModel() as! T
        }

        if type == FavoriteProductsViewModel.self {
            return self.container.favoriteProductsViewModel() as! T
        }

        if type == ProductDetailsViewModel.self {
            return self.container.productDetailsViewModel() as! T
        }

        if type == StoreAccountViewModel.self {
            return self.container.storeAccountViewModel() as! T
        }

        if type == AlertServiceProtocol.self {
            return self.container.alertService() as! T
        }

        if type == RootViewModel.self {
            return self.container.rootViewModel() as! T
        }

        if type == MainViewModel.self {
            return self.container.mainViewModel() as! T
        }

        if type == HomeViewModel.self,
           let viewModel = self.container.homeViewModel() as? T {
            return viewModel
        }

        if type == WelcomeViewModel.self {
            return self.container.welcomeViewModel() as! T
        }

        if type == LoginViewModel.self {
            return self.container.loginViewModel() as! T
        }

        if type == SignUpViewModel.self {
            return self.container.signUpViewModel() as! T
        }

        if type == SettingsViewModel.self {
            return self.container.settingsViewModel() as! T
        }

        if type == LegalViewModel.self {
            return self.container.legalViewModel() as! T
        }

        if type == DevSettingsViewModel.self {
            return self.container.devSettingsViewModel() as! T
        }

        if type == DevRoutesViewModel.self {
            return self.container.devRoutesViewModel() as! T
        }

        if type == DevDeeplinksViewModel.self {
            return self.container.devDeeplinksViewModel() as! T
        }

        if type == DevUserDefaultsViewModel.self {
            return self.container.devUserDefaultsViewModel() as! T
        }

        if type == DevAnalyticsViewModel.self {
            return self.container.devAnalyticsViewModel() as! T
        }

        fatalError("No mock Factory registration for \(type)")

    }

}

private struct PreviewWrapper<Content: View>: View {

    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {

        content()
            .withWindowAlertService(ObservableAlertServiceWrapper(alertService: mockResolve(AlertServiceProtocol.self)))

    }

}

extension View {

    func withMockPreviews() -> some View {

        AppBaseView {
            self
        }
        .withMockServices()

    }

    func withMockServices(withNaivgationService: Bool = true) -> some View {

        PreviewWrapper {
            self
        }
        .if(withNaivgationService) { view in
            view.environment(NavigationService())
        }
        .withWindowToastOverlay()
        .withWindowTooltipOverlay()
        .withWindowDynamicIslandService()
        .environment(TabBarNavigationService())
        .runeStyle()

    }

}

// Global function for resolving mock dependencies
func mockResolve(_ type: (any AlertServiceProtocol).Type) -> any AlertServiceProtocol {
    MockAppAssembler.shared.container.alertService()
}

// Global function for resolving mock dependencies
func mockResolve<T>(_ type: T.Type) -> T {
    MockAppAssembler.shared.resolve(type)
}

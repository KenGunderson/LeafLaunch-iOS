//
//  NavigationService.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 7/15/24.
//

import SwiftUI
import Combine
import FactoryKit

@Observable
final class NavigationService: NavigationServiceProtocol, Equatable {

    static func == (lhs: NavigationService, rhs: NavigationService) -> Bool {

        // Each navigation stack must remain a distinct SwiftUI environment value.
        lhs === rhs

    }

    var routes: [Route] = []
    var fullScreenCover: FullScreenCover?
    var sheet: NavigationSheet?

    private var replaceStackTask: Task<Void, Never>?

    isolated deinit {
        self.replaceStackTask?.cancel()
    }

    func push(_ route: Route) {
        self.routes.append(route)
    }

    func push(_ routes: [Route]) {
        self.routes.append(contentsOf: routes)
    }

    func pop() {

        guard !self.routes.isEmpty else { return }
        self.routes.removeLast()

    }

    func popWithDelay(_ delay: TimeInterval = 0.2) {

        guard !self.routes.isEmpty else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.routes.removeLast()
        }

    }

    func popLast(count: Int) {

        guard count > 0 else { return }
        guard !self.routes.isEmpty else { return }

        let safeCount = min(count, self.routes.count)
        self.routes.removeLast(safeCount)

    }

    func popToRoot() {
        self.routes = []
    }

    func swap(_ route: Route) {

        self.routes.removeLast()
        self.routes.append(route)

    }

    func replaceStack(_ route: Route) {

        self.routes.removeAll()
        self.replaceStackTask?.cancel()

        self.replaceStackTask = Task { @MainActor [weak self] in
            //The time delay may be device/app specific.
            try? await Task.sleep(nanoseconds: 400_000_000)
            guard !Task.isCancelled else { return }
            self?.push(route)

        }

    }

    // FullScreenCover

    func modal(fullScreenCover: FullScreenCover) {
        self.fullScreenCover = fullScreenCover
    }

    func dismissFullScreenCover() {
        self.fullScreenCover = nil
    }

    func modal(sheet: NavigationSheet) {
        self.sheet = sheet
    }

    func dismissSheet() {
        self.sheet = nil
    }

}

extension View {

    func withNavigationDestination() -> some View {

        return navigationDestination(for: Route.self) { route in

            switch route {
            case .auth(let route): auth(route: route)
            case .settings(let route): settings(route: route)
            case .devSetting(let route): devSettings(route: route)
            case .customer(let route): customer(route: route)
            }

        }

        @ViewBuilder
        func customer(route: Route.CustomerRoute) -> some View {

            switch route {
            case .product(let locationId, let productId):

                let viewModel = Container.shared.productDetailsViewModel()
                    .setup(locationId: locationId, productId: productId)

                ProductDetailsScreen(viewModel: viewModel)
                    .navigationBarBackButtonHidden()

            case .favoriteProducts(let locationId):

                let viewModel = Container.shared.favoriteProductsViewModel()
                    .setup(locationId: locationId)

                FavoriteProductsScreen(viewModel: viewModel)
                    .navigationBarBackButtonHidden()

            case .pointsActivity(let locationId):

                let viewModel = Container.shared.pointsActivityViewModel()
                    .setup(locationId: locationId)

                PointsActivityScreen(viewModel: viewModel)
                    .navigationBarBackButtonHidden()

            case .events(let locationId):

                let viewModel = Container.shared.storeEventsViewModel()
                    .setup(locationId: locationId)

                StoreEventsScreen(viewModel: viewModel)
                    .navigationBarBackButtonHidden()

            case .event(let locationId, let event):

                let viewModel = Container.shared.eventDetailsViewModel()
                    .setup(locationId: locationId, event: event)

                EventDetailsScreen(viewModel: viewModel)
                    .navigationBarBackButtonHidden()

            case .promotionProducts(let locationId, let promotionId, let title, let products):

                let viewModel = Container.shared.promotionProductsViewModel()
                    .setup(locationId: locationId, promotionId: promotionId, title: title, products: products)

                PromotionProductsScreen(viewModel: viewModel)
                    .navigationBarBackButtonHidden()

            }

        }

        @ViewBuilder
        func auth(route: Route.AuthRoute) -> some View {

            switch route {
            case .welcome:

                let viewModel = Container.shared.welcomeViewModel()

                WelcomeScreen(viewModel: viewModel)
                    .navigationBarBackButtonHidden()

            case .login:

                let viewModel = Container.shared.loginViewModel()

                LoginScreen(viewModel: viewModel)
                    .navigationBarBackButtonHidden()

            case .signup:

                let viewModel = Container.shared.signUpViewModel()

                SignUpScreen(viewModel: viewModel)
                    .navigationBarBackButtonHidden()
            }

        }

        @ViewBuilder
        func settings(route: Route.SettingRoute) -> some View {

            switch route {
            case .contactSupport: EmptyView()
            case .rateApp: EmptyView()
            case .privacyPolicy:

                let viewModel = Container.shared.legalViewModel()
                    .setup(context: .privacyPolicy)

                LegalScreen(viewModel: viewModel)
                    .navigationBarBackButtonHidden()

            case .termsOfService:

                let viewModel = Container.shared.legalViewModel()
                    .setup(context: .termsAndConditions)

                LegalScreen(viewModel: viewModel)
                    .navigationBarBackButtonHidden()

            case .logout: EmptyView()
            }

        }

        @ViewBuilder
        func devSettings(route: Route.DevSettingRoute) -> some View {

            switch route {
            case .userDefaults:

                let viewModel = Container.shared.devUserDefaultsViewModel()

                DevUserDefaultsScreen(viewModel: viewModel)
                    .navigationBarBackButtonHidden()

            case .routes:

                let viewModel = Container.shared.devRoutesViewModel()

                DevRoutesScreen(viewModel: viewModel)
                    .navigationBarBackButtonHidden()

            case .deeplinks:

                let viewModel = Container.shared.devDeeplinksViewModel()

                DevDeeplinksScreen(viewModel: viewModel)
                    .navigationBarBackButtonHidden()

            case .analytics:

                let viewModel = Container.shared.devAnalyticsViewModel()

                DevAnalyticsScreen(viewModel: viewModel)
                    .navigationBarBackButtonHidden()

            }

        }

    }

    func withFullScreenCover(_ customFullScreenCover: Binding<FullScreenCover?>) -> some View {

        return fullScreenCover(item: customFullScreenCover) { fullScreenCover in

            switch fullScreenCover {
            case .devSettings:

                let viewModel = Container.shared.devSettingsViewModel()
                DevSettingsScreen(viewModel: viewModel)

            case .settings:

                let viewModel = Container.shared.settingsViewModel()
                SettingsScreen(viewModel: viewModel)
            }

        }

    }

    func withSheet(_ navigationSheet: Binding<NavigationSheet?>,
                   onDismiss: (() -> Void)? = nil) -> some View {

        sheet(item: navigationSheet, onDismiss: onDismiss) { sheet in

            switch sheet {
            case .locations:

                let viewModel = Container.shared.locationsViewModel()

                LocationsScreen(viewModel: viewModel)

            case .ageVerification(let locationId):

                let viewModel = Container.shared.ageVerificationViewModel()
                    .setup(locationId: locationId)

                AgeVerificationScreen(viewModel: viewModel)
                    .interactiveDismissDisabled()

            }

        }

    }

}

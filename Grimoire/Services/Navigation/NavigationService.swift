//
//  NavigationService.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 7/15/24.
//

import SwiftUI
import Combine
import FactoryKit

@Observable
final class NavigationService: NavigationServiceProtocol, Equatable {
    
    static func == (lhs: NavigationService, rhs: NavigationService) -> Bool {
        
        lhs.routes == rhs.routes &&
        lhs.sheet == rhs.sheet &&
        lhs.fullScreenCover == rhs.fullScreenCover
        
    }
    
    var routes: [Route] = []
    var sheet: Sheet?
    var fullScreenCover: FullScreenCover?
    
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
    
    // Sheets
    
    func modal(sheet: Sheet) {
        self.sheet = sheet
    }
    
    func dismissSheet() {
        self.sheet = nil
    }
    
    // FullScreenCover
    
    func modal(fullScreenCover: FullScreenCover) {
        self.fullScreenCover = fullScreenCover
    }
    
    func dismissFullScreenCover() {
        self.fullScreenCover = nil
    }
    
}

extension View {
    
    func withNavigationDestination() -> some View {
        
        return navigationDestination(for: Route.self) { route in
            
            switch route {
            case .auth(let route): auth(route: route)
            case .onboarding(let route): onboarding(route: route)
            case .settings(let route): settings(route: route)
            case .devSetting(let route): devSettings(route: route)
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
        func onboarding(route: Route.OnboardingRoute) -> some View {
            
            switch route {
            case .businessSetup:
                
                OnboardingFeaturesScreen(onboardingPage: .businessSetup)
                    .navigationBarBackButtonHidden()
                
            case .locationControl:
                
                OnboardingFeaturesScreen(onboardingPage: .locationControl)
                    .navigationBarBackButtonHidden()
                
            case .photos:
                
                OnboardingFeaturesScreen(onboardingPage: .photos)
                    .navigationBarBackButtonHidden()
                
            case .beforeAndAfter:
                
                OnboardingFeaturesScreen(onboardingPage: .beforeAndAfter)
                    .navigationBarBackButtonHidden()
                
            case .documentation:
                
                OnboardingFeaturesScreen(onboardingPage: .documentation)
                    .navigationBarBackButtonHidden()
                
            case .permission:
                
                let viewModel = Container.shared.onboardingPermissionsViewModel()
                
                OnboardingPermissionsScreen(viewModel: viewModel)
                    .navigationBarBackButtonHidden()
            }
            
        }
        
        @ViewBuilder
        func settings(route: Route.SettingRoute) -> some View {
            
            switch route {
            case .profile:
                
                let viewModel = Container.shared.profileViewModel()
                ProfileScreen(viewModel: viewModel)
                
            case .updatePermissions: EmptyView()
            case .aboutUs:
                
                let viewModel = Container.shared.aboutUsViewModel()
                
                AboutUsScreen(viewModel: viewModel)
                    .navigationBarBackButtonHidden()
                
            case .frequentlyAskedQuestions:
                
                let viewModel = Container.shared.faqViewModel()
                
                FAQScreen(viewModel: viewModel)
                    .navigationBarBackButtonHidden()
                
            case .contactSupport: EmptyView()
            case .rateApp: EmptyView()
            case .featureRequest:
                
                let viewModel = Container.shared.featureRequestViewModel()
                
                FeatureRequestScreen(viewModel: viewModel)
                    .navigationBarBackButtonHidden()
                
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

            case .impersonate:
                
                let viewModel = Container.shared.devImpersonateViewModel()
                
                DevImpersonateScreen(viewModel: viewModel)
                    .navigationBarBackButtonHidden()
            }
            
        }
        
    }
    
    func withSheetDestination(_ customSheet: Binding<Sheet?>) -> some View {
        
        /// DEV-NOTE: Add `presentationBackground` modifier to presenting view to avoid flickering; Apple bug
        
        // We do this for SE Phones
//        let halfSheet = 0.60
//        let iphoneSESheet = 0.70
//
//        let isModernDevice: Bool = UIDevice.isModernDevice
        
        return sheet(item: customSheet) { sheet in
            
            switch sheet {
            case .whatsNew:
                
                let defaultItem: WhatsNewItem = .init(version: .init("0.0.0"), items: [])

                let viewModel = Container.shared.whatsNewViewModel()
                    .setup(whatsNewItem: Constants.WhatsNewItems.items.last ?? defaultItem)
                
                WhatsNewScreen(viewModel: viewModel)
                
            case .permissions:
                
                Color.indigo.ignoresSafeArea()
            }
            
        }
        
    }
    
    func withFullScreenCover(_ customFullScreenCover: Binding<FullScreenCover?>) -> some View {
        
        return fullScreenCover(item: customFullScreenCover) { fullScreenCover in
            
            switch fullScreenCover {
            case .devSettings:
                
                let viewModel = Container.shared.devSettingsViewModel()
                DevSettingsScreen(viewModel: viewModel)
                
            case .onboarding:
                
                let viewModel = Container.shared.onboardingViewModel()
                    .setup(pages: [
                        .businessSetup,
                        .locationControl,
                        .photos,
                        .beforeAndAfter,
                        .documentation,
                        .permission
                    ])
                
                OnboardingScreen(viewModel: viewModel)
            case .settings:
                
                let viewModel = Container.shared.settingsViewModel()
                SettingsScreen(viewModel: viewModel)
            }
            
        }
        
    }
    
}

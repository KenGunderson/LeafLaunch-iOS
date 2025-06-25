//
//  NavigationService.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 7/15/24.
//

import SwiftUI
import Combine

@Observable
class NavigationService: NavigationServiceProtocol {
    
    public var routes: [Route] = []
    public var sheet: Sheet?
    public var fullScreenCover: FullScreenCover?
    
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
    
    func popToRoot() {
        self.routes = []
    }
    
    func swap(_ route: Route) {
        
        self.routes.removeLast()
        self.routes.append(route)
        
    }
    
    func replaceStack(_ route: Route) {
        
        self.routes.removeAll()
        
        Task { @MainActor in
            //The time delay may be device/app specific.
            try? await Task.sleep(nanoseconds: 400_000_000)
            await MainActor.run { [weak self] in
                self?.push(route)
            }
            
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
    
    /// Optional Param for more control? `navigationService: NavigationService? = nil`
    func withNavigationDestination() -> some View {
        
        return navigationDestination(for: Route.self) { route in
            
            switch route {
            case .auth(let route): auth(route: route)
            case .setting(let route): settings(route: route)
            case .devSetting(let route): devSettings(route: route)
            case .businessEditDetail(let id):
                
                let viewModel = globalResolver.resolve(BusinessEditDetailsViewModel.self)!
                    .setup(businessId: id)
                
                BusinessEditDetailsScreen(viewModel: viewModel)
                    .navigationBarBackButtonHidden()
                
            case .clientList:
                
                let viewModel = globalResolver.resolve(ClientListViewModel.self)!
                
                ClientListScreen(viewModel: viewModel)
                    .navigationBarBackButtonHidden()
                
            }
            
        }
        
        @ViewBuilder
        func auth(route: Route.Auth) -> some View {
            
            switch route {
            case .welcome:
                
                let viewModel = globalResolver.resolve(WelcomeViewModel.self)!
                
                WelcomeScreen(viewModel: viewModel)
                    .navigationBarBackButtonHidden()
                
            case .login:
                
                let viewModel = globalResolver.resolve(LoginViewModel.self)!
                
                LoginScreen(viewModel: viewModel)
                    .navigationBarBackButtonHidden()
                
            case .signup:
                
                let viewModel = globalResolver.resolve(SignUpViewModel.self)!
                
                SignUpScreen(viewModel: viewModel)
                    .navigationBarBackButtonHidden()
            }
            
        }
        
        @ViewBuilder
        func settings(route: Route.Setting) -> some View {
            
            switch route {
            case .profile: EmptyView()
            case .subscription: EmptyView()
            case .aboutUs: EmptyView()
            case .frequentlyAskedQuestions:
                
                let viewModel = globalResolver.resolve(FAQViewModel.self)!
                
                FAQScreen(viewModel: viewModel)
                    .navigationBarBackButtonHidden()
                
            case .contactSupport: EmptyView()
            case .sendFeedback: EmptyView()
            case .privacyPolicy: EmptyView()
            case .termsOfService: EmptyView()
            }
            
        }
        
        @ViewBuilder
        func devSettings(route: Route.DevSetting) -> some View {
            
            switch route {
            case .components:
                
                DemoView()
                    .navigationBarBackButtonHidden()
                
            case .userDefaults:
                
                let viewModel = globalResolver.resolve(DevUserDefaultsViewModel.self)!
                
                DevUserDefaultsScreen(viewModel: viewModel)
                    .navigationBarBackButtonHidden()
                
            case .routes:
                                    
                let viewModel = globalResolver.resolve(DevRoutesViewModel.self)!
                
                DevRoutesScreen(viewModel: viewModel)
                    .navigationBarBackButtonHidden()
                
            case .deeplinks:
                
                let viewModel = globalResolver.resolve(DevDeeplinksViewModel.self)!
                
                DevDeeplinksScreen(viewModel: viewModel)
                    .navigationBarBackButtonHidden()
                
            case .analytics:
                                    
                let viewModel = globalResolver.resolve(DevAnalyticsViewModel.self)!
                
                DevAnalyticsScreen(viewModel: viewModel)
                    .navigationBarBackButtonHidden()

            case .impersonate:
                
                let viewModel = globalResolver.resolve(DevImpersonateViewModel.self)!
                
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
                
                let viewModel = globalResolver.resolve(WhatsNewViewModel.self)!
                    .setup(whatsNewItem: Constants.WhatsNewItems.items.last!)
                
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
                
                let viewModel = globalResolver.resolve(DevSettingsViewModel.self)!
                DevSettingsScreen(viewModel: viewModel)
                
            case .onboarding:
                
                Color.orange
                    .onTapGesture {
                        customFullScreenCover.wrappedValue = nil
                    }
            
            case .settings:
                
                let viewModel = globalResolver.resolve(SettingsViewModel.self)!
                SettingsScreen(viewModel: viewModel)
                
            case .clientDetails(let clientId):
                
                let viewModel = globalResolver.resolve(ClientDetailsViewModel.self)!
                    .setup(clientId: clientId)
                
                ClientDetailsScreen(viewModel: viewModel)
                
            }
            
        }
        
    }
    
}

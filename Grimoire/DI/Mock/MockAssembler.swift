//
//  MockAssembly.swift
//  Grimoire 
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
        
    }
    
    func resolve<T>(_ type: T.Type) -> T {
        
        switch type {
        case is AlertServiceProtocol.Type:
            return self.container.alertService() as! T
        case is RootViewModel.Type:
            return self.container.rootViewModel() as! T
        case is MainViewModel.Type:
            return self.container.mainViewModel() as! T
        case is WelcomeViewModel.Type:
            return self.container.welcomeViewModel() as! T
        case is LoginViewModel.Type:
            return self.container.loginViewModel() as! T
        case is SignUpViewModel.Type:
            return self.container.signUpViewModel() as! T
        case is OnboardingViewModel.Type:
            return self.container.onboardingViewModel() as! T
        case is OnboardingPermissionsViewModel.Type:
            return self.container.onboardingPermissionsViewModel() as! T
        case is Tab1ViewModel.Type:
            return self.container.tab1ViewModel() as! T
        case is Tab2ViewModel.Type:
            return self.container.tab2ViewModel() as! T
        case is Tab3ViewModel.Type:
            return self.container.tab3ViewModel() as! T
        case is Tab4ViewModel.Type:
            return self.container.tab4ViewModel() as! T
        case is SettingsViewModel.Type:
            return self.container.settingsViewModel() as! T
        case is ProfileViewModel.Type:
            return self.container.profileViewModel() as! T
        case is AboutUsViewModel.Type:
            return self.container.aboutUsViewModel() as! T
        case is FeatureRequestViewModel.Type:
            return self.container.featureRequestViewModel() as! T
        case is FAQViewModel.Type:
            return self.container.faqViewModel() as! T
        case is LegalViewModel.Type:
            return self.container.legalViewModel() as! T
        case is DevSettingsViewModel.Type:
            return self.container.devSettingsViewModel() as! T
        case is DevRoutesViewModel.Type:
            return self.container.devRoutesViewModel() as! T
        case is DevDeeplinksViewModel.Type:
            return self.container.devDeeplinksViewModel() as! T
        case is DevUserDefaultsViewModel.Type:
            return self.container.devUserDefaultsViewModel() as! T
        case is DevAnalyticsViewModel.Type:
            return self.container.devAnalyticsViewModel() as! T
        case is DevImpersonateViewModel.Type:
            return self.container.devImpersonateViewModel() as! T
        default:
            fatalError("No mock Factory registration for \(type)")
        }
        
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

    func withMockServices(withNaivgationService: Bool = true) -> some View {
        
        PreviewWrapper {
            self
        }
        .if(withNaivgationService) { view in
            view.environment(NavigationService())
        }
        .withWindowToastOverlay()
        
    }
    
}

// Global function for resolving mock dependencies
func mockResolve<T>(_ type: T.Type) -> T {
    MockAppAssembler.shared.resolve(type)
}

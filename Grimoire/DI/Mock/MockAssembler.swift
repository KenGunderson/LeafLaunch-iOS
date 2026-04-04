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
        
        if type == AlertServiceProtocol.self {
            return self.container.alertService() as! T
        }
        
        if type == RootViewModel.self {
            return self.container.rootViewModel() as! T
        }
        
        if type == MainViewModel.self {
            return self.container.mainViewModel() as! T
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
        
        if type == OnboardingViewModel.self {
            return self.container.onboardingViewModel() as! T
        }
        
        if type == OnboardingPermissionsViewModel.self {
            return self.container.onboardingPermissionsViewModel() as! T
        }
        
        if type == Tab1ViewModel.self {
            return self.container.tab1ViewModel() as! T
        }
        
        if type == Tab2ViewModel.self {
            return self.container.tab2ViewModel() as! T
        }
        
        if type == Tab3ViewModel.self {
            return self.container.tab3ViewModel() as! T
        }
        
        if type == Tab4ViewModel.self {
            return self.container.tab4ViewModel() as! T
        }
        
        if type == SettingsViewModel.self {
            return self.container.settingsViewModel() as! T
        }
        
        if type == ProfileViewModel.self {
            return self.container.profileViewModel() as! T
        }
        
        if type == AboutUsViewModel.self {
            return self.container.aboutUsViewModel() as! T
        }
        
        if type == FeatureRequestViewModel.self {
            return self.container.featureRequestViewModel() as! T
        }
        
        if type == FAQViewModel.self {
            return self.container.faqViewModel() as! T
        }
        
        if type == LegalViewModel.self {
            return self.container.legalViewModel() as! T
        }
        
        if type == WhatsNewViewModel.self {
            return self.container.whatsNewViewModel() as! T
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
        
        if type == DevImpersonateViewModel.self {
            return self.container.devImpersonateViewModel() as! T
        }
        
        if type == DevLocalNotificationsViewModel.self {
            return self.container.devLocalNotificationsViewModel() as! T
        }

        if type == DevVoiceViewModel.self {
            return self.container.devVoiceViewModel() as! T
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

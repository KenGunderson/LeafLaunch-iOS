//
//  MainView.swift
//  GlowPro 
//
//  Created by Sako Hovaguimian on 7/15/24.
//

import SwiftUI

struct MainScreen: View {
    
    @StateObject var viewModel: MainViewModel
    @Environment(TabBarNavigationService.self) private var tabBarNavigationService
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
            backgroundView
            
            if self.viewModel.shouldShowTabBarScreen {
                
                tabScreen
                    .transition(.opacity)
                
            }
            
            if self.viewModel.shouldShowWelcomeScreen {
                
                WelcomeScreen(viewModel: self.viewModel.welcomeViewModel)
                    .transition(.opacity)
                
            }
            
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
        
        // Lifecycle
        
        .onFirstAppear {
            
            self.viewModel
                .track()
            
            self.viewModel
                .setup(tabBarNavigationService: self.tabBarNavigationService)
            
        }
        
        // Errors
        
//        .errorHandler(
//            error: Bindable(ErrorManager.shared).error,
//            alertStyle: ErrorManager.shared.alertStyle
//        )
        
        // Animations
        
        .animation(
            .easeInOut(duration: 1),
            value: self.viewModel.userDefaultsService.didCompleteOnboarding
        )
        .animation(
            .easeInOut(duration: 1),
            value: self.viewModel.shouldShowTabBarScreen
        )
        .animation(
            .smooth(duration: 1),
            value: self.viewModel.shouldShowWelcomeScreen
        )
        
    }
    
    private var backgroundView: some View {
     
        Style
            .shared
            .background(.primary)
            .view()
            .ignoresSafeArea()
        
    }
    
    private var tabScreen: some View {
        
        let nav = Bindable(self.tabBarNavigationService)
        
        return TabBarScreen(
            selectedTab: nav.selectedTab,
            isTabBarVisibile: nav.isTabBarVisible,
            tab1ViewModel: self.viewModel.tab1ViewModel,
            tab2ViewModel: self.viewModel.tab2ViewModel,
            tab3ViewModel: self.viewModel.tab3ViewModel,
            tab4ViewModel: self.viewModel.tab4ViewModel
        )
        .transition(.opacity.combined(with: .blurReplace))
        .onChange(of: self.tabBarNavigationService.selectedTab) { oldValue, newValue in
            
            self.viewModel
                .track(tab: newValue)
            
        }
        
    }
    
}

#Preview {
    
    MainScreen(
        viewModel: mockResolve(MainViewModel.self)
    )
    .withMockServices()
    
}

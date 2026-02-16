//
//  MainView.swift
//  Grimoire 
//
//  Created by Sako Hovaguimian on 7/15/24.
//

import SwiftUI

struct MainScreen: GPView {
    
    @StateObject var viewModel: MainViewModel
    @Environment(TabBarNavigationService.self) private var tabBarNavigationService
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
            backgroundView
            
            if self.viewModel.showShouldHomeScreen {
                
                let nav = Bindable(self.tabBarNavigationService)
                
                TabBarScreen(
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
            
            if self.viewModel.shouldShowWelcomeScreen {
                
                WelcomeScreen(viewModel: self.viewModel.welcomeViewModel)
                    .environment(self.tabBarNavigationService.tab1NavigationService)
                    .transition(.opacity)
                
            }
            
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
        
        .withWindowToastOverlay()
        .withWindowAlertService(.init(alertService: self.viewModel.alertService))
        .withWindowDynamicIslandService()
        
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
            value: self.viewModel.showShouldHomeScreen
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
    
}

#Preview {
    
    MainScreen(
        viewModel: mockResolve(MainViewModel.self)
    )
    .withMockServices()
    
}

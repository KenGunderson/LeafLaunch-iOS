//
//  MainView.swift
//  GlowPro 
//
//  Created by Sako Hovaguimian on 7/15/24.
//

import SwiftUI

struct MainScreen: GPView {
    
    @StateObject var viewModel: MainViewModel
    @Environment(NavigationService.self) private var navigationService
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
            backgroundView

            if self.viewModel.showShouldHomeScreen {
                
                HomeScreen(viewModel: self.viewModel.homeViewModel)
                    .transition(.opacity.combined(with: .blurReplace))
                
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
                .setup(navigationService: self.navigationService)
            
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

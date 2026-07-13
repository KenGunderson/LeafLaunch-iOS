//
//  RootView.swift
//  Grimoire 
//
//  Created by Sako Hovaguimian on 7/14/24.
//

import SwiftUI
import FactoryKit

struct RootScreen: GPView {

    @Environment(\.style) private var style
    
    @StateObject var viewModel: RootViewModel    
    @State private var shouldShowHealthCheckView: Bool = false
    @State private var tabBarNavigationService = TabBarNavigationService()
    
    var body: some View {
     
        ZStack {
            
            backgroundView()
            mainView()
            splashScreenView()
            
        }
        .environment(self.tabBarNavigationService)
        
        // Lifecycle
        
        .onFirstAppear { [weak viewModel] in
            
            viewModel?
                .track()
            
        }
        
        .onAppear { [weak viewModel] in
            
            viewModel?
                .setNavigationService(self.tabBarNavigationService)
            
            globalTabBarNavigationService = self.tabBarNavigationService
            
        }
        
        
        // Deeplinks
        
        .onOpenURL { url in
            self.viewModel.setDeeplink(url: url)
        }
        // Full Screen Cover
        
        .fullScreenCover(isPresented: self.$viewModel.shouldPresentDevSettings) {
            
            let viewModel = Container.shared.devSettingsViewModel()
            DevSettingsScreen(viewModel: viewModel)
            
        }
        
    }
    
    private func backgroundView() -> some View {
        
        self.style
            .background(.primary)
            .view()
            .ignoresSafeArea()
        
    }
    
    private func mainView() -> some View {
        
        GeometryReader { _ in
            
            VStack(spacing: self.style.spacing(.none)) {
                                        
                MainScreen(viewModel: self.viewModel.mainViewModel)
                    .restrictCapture(self.viewModel.userDefaultsService.shouldHideScreenshots)
                
            }
            
        }
        
    }
    
    private func splashScreenView() -> some View {
        
        SplashScreenView {
                        
            self.viewModel
                .markSplashAnimationCompleted()
                        
        }
        .opacity(self.viewModel.launchState == .completed ? 0 : 1)
        .animation(.smooth(duration: 0.6), value: viewModel.launchState)
        .onFirstAppear { [weak viewModel] in
            
            viewModel?
                .trackLauchScreen()
            
        }
        
    }
    
}

#Preview {
    
    RootScreen(
        viewModel: mockResolve(RootViewModel.self)
    )
    .withMockServices()
    
}

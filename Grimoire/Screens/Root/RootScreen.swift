//
//  RootView.swift
//  Grimoire 
//
//  Created by Sako Hovaguimian on 7/14/24.
//

import SwiftUI
import FactoryKit

struct RootScreen: GPView {
    
    @StateObject var viewModel: RootViewModel    
    @State private var shouldShowHealthCheckView: Bool = false
    @State private var tabBarNavigationService = TabBarNavigationService()
    
    var body: some View {
     
        ZStack {
            
            backgroundView()
            
            if self.viewModel.isImpersonatingUser {
                
                impersonateLinearGradient()
                    .ignoresSafeArea()
                
            }
            
            mainView()
            splashScreenView()
            
        }
        .environment(self.tabBarNavigationService)
        
        // Lifecycle
        
        .onFirstAppear {
            
            self.viewModel
                .track()
            
        }
        
        .onAppear {
            
            self.viewModel
                .setNavigationService(self.tabBarNavigationService)
            
            globalTabBarNavigationService = self.tabBarNavigationService
            
        }
        
        
        // Deeplinks
        
        .onOpenURL { url in
            self.viewModel.setDeeplink(url: url)
        }
        
        // Animations
        
        .animation(
            .bouncy,
            value: self.viewModel.isImpersonatingUser
        )
        
        // Dev Settings
        
        .simultaneousGesture(LongPressGesture(minimumDuration: 2.5).onEnded { _ in
            
            self.viewModel
                .presentDevSettings()
            
        })
        
        // Full Screen Cover
        
        .fullScreenCover(isPresented: self.$viewModel.shouldPresentDevSettings) {
            
            let viewModel = Container.shared.devSettingsViewModel()
            DevSettingsScreen(viewModel: viewModel)
            
        }
        
    }
    
    private func backgroundView() -> some View {
        
        Style.shared
            .background(.primary)
            .view()
            .ignoresSafeArea()
        
    }
    
    private func mainView() -> some View {
        
        GeometryReader { _ in
            
            VStack(spacing: Style.shared.spacing(.none)) {
                                        
                if self.viewModel.isImpersonatingUser {
                    impersonatingUserBannerView()
                }
                
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
        .onFirstAppear {
            self.viewModel.trackLauchScreen()
        }
        
    }
    
    private func impersonatingUserBannerView() -> some View {
        
        let darkColor = Color(uiColor: .systemIndigo)
        
        return HStack(spacing: Style.shared.spacing(.small)) {
            
            Image(systemName: "person.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(
                    width: 24,
                    height: 24
                )
                .padding(.small)
                .background(darkColor)
                .clipShape(.circle)
            
            VStack(alignment: .leading, spacing: Style.shared.spacing(.extraSmall)) {
                
                Text("Impersonating \(self.viewModel.impersonatingUserEmail)")
                    .appFont(with: .TITLE_5)
                    .multilineTextAlignment(.center)
                
                Text("Revert")
                    .appFont(with: .TITLE_3)
                    .padding(.vertical, Style.shared.spacing(.extraSmall))
                    .padding(.horizontal, Style.shared.spacing(.medium))
                    .background(darkColor)
                    .clipShape(.capsule)
                    .asButton {
                        self.viewModel.revertImpersonatingUser()
                    }
                
            }
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, .medium)
        .padding(.bottom, .medium)
        .foregroundStyle(.white)
        .transition(.move(edge: .top))
        
    }
    
    private func impersonateLinearGradient() -> LinearGradient {
        
        let lightColor = Color(uiColor: .systemIndigo)
        let darkColor = Color(uiColor: .systemMint)
        
        return LinearGradient(
            gradient: Gradient(colors: [lightColor.opacity(0.6), darkColor.opacity(0.6)]),
            startPoint: .leading,
            endPoint: .trailing
        )

    }
    
}

#Preview {
    
    RootScreen(
        viewModel: mockResolve(RootViewModel.self)
    )
    .withMockServices()
    
}

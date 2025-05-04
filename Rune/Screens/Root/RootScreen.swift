//
//  RootView.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 7/14/24.
//

import SwiftUI

struct RootScreen: View {
    
    @StateObject var viewModel: RootViewModel
    @State private var tabBarNavigationService = TabBarNavigationService()
    
    @State private var shouldShowHealthCheckView: Bool = false
    
    var body: some View {
     
        ZStack {
            
            backgroundView()
            
            if self.viewModel.isImpersonatingUser {
                
                impersonateLinearGradient()
                    .ignoresSafeArea()
                
            }
            
            mainView()
            splashScreenView()
            
//            CommonButton(title: "Deeplink") {
//                viewModel.setDeeplink(url: URL(string: "rune://host/tab?tab=tab\(Int.random(in: 1...4))")!)
//            }
            
//            CommonButton(title: "Toast") {
//                
//                ToastManager.shared.present(toastItem: .init(
//                    title: "My Toast",
//                    titleColor: .color(.white),
//                    messageColor: .color(.white),
//                    image: .systemImage("person.fill"),
//                    tint: .color(.white)
//                ))
//                
//            }
            
        }
        .withAlertService(ObservableAlertServiceWrapper(alertService: self.viewModel.alertService))
        .environmentObject(ObservableAlertServiceWrapper(alertService: self.viewModel.alertService))
        .environment(self.tabBarNavigationService)
        .preferredColorScheme(.light)
        .withToastOverlay()
        
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
        
        .simultaneousGesture(LongPressGesture(minimumDuration: 3).onEnded { _ in
            
            self.viewModel
                .presentDevSettings()
            
        })
        
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
                
            }
            
        }
        
    }
    
    private func splashScreenView() -> some View {
        
        SplashScreenView { launcState in
            
            self.viewModel
                .setLaunchState(launcState)
            
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
                    .appFont(with: .TITLE_T6)
                    .multilineTextAlignment(.center)
                
                Text("Revert")
                    .appFont(with: .TITLE_T4)
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
        .padding(.horizontal, Style.shared.spacing(.large))
        .padding(.bottom, Style.shared.spacing(.medium))
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

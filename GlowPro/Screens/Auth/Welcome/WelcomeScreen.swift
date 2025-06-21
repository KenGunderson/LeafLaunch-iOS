//
//  WelcomeScreen.swift
//  GlowPro 
//
//  Created by Sako Hovaguimian on 5/16/25.
//

import SwiftUI

struct WelcomeScreen: GPView {
    
    @StateObject var viewModel: WelcomeViewModel
    @State private var navigationService = NavigationService()
        
    var body: some View {
        
        AppRootView(
            navigationService: self.$navigationService,
            alertService: self.viewModel.alertService
        ) {
            
            ZStack(alignment: .center) {
                
                backgroundView
                content
                
            }
            .safeAreaInset(edge: .bottom) {
                footer
            }
            
            .onFirstAppear {
                
                self.viewModel
                    .track()
                
                self.viewModel
                    .setup(navigationService: self.navigationService)
                
            }
            
        }
        
    }
    
    var backgroundView: some View {
        
        LinearGradient(
            colors: [
                Style.shared.accent.asColor ?? .clear,
                Style.shared.accentSecondary.asColor ?? .clear,
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        
    }
    
    var content: some View {
        
        VStack(spacing: Style.shared.spacing(.custom(64))) {
            
            VStack {
                
                Text("Welcome To\nGlowPro")
                    .appFont(with: .HEADER_H1)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)
                
            }
            .frame(maxWidth: .infinity)
            
            Spacer(minLength: 0)
            
        }
        .padding(.top, .extraLarge)
        
    }
    
    var footer: some View {
        
        VStack(spacing: 16) {
            
            signUpButton
            loginButton
            
        }
        .padding(.horizontal, 32)
        .customSafeAreaPadding()
        
    }
    
    var signUpButton: some View {
        
        CommonButton(
            title: "Sign Up",
            titleColor: Style.shared.textColor(.titleInverted),
            action: {
                self.viewModel.navigateToSignUp()
            })
        
    }
    
    var loginButton: some View {
        
        CommonButton(
            title: "Login",
            titleColor: Style.shared.textColor(.titleInverted),
            action: {
                self.viewModel.navigateToLogin()
            })
        
    }
    
}

#Preview {
    
    WelcomeScreen(
        viewModel: mockResolve(WelcomeViewModel.self)
    )
    .withMockServices()
    
}

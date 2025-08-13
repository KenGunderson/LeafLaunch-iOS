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
            
            content
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
    
    var content: some View {
        
        VStack(spacing: Style.shared.spacing(.extraLarge)) {
            
            RoundedRectangle(cornerRadius: Style.shared.radius(.large))
                .fill(.gray.opacity(0.15))
                .frame(height: 360)
            
            VStack(spacing: Style.shared.spacing(.large)) {
                
                Text("GlowPro")
                    .appFont(with: .BILLBOARD_1)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Style.shared.textColor(.title).source())
                
                Text("Capture your clients' transformations beautifully and professionally.")
                    .appFont(with: .BODY_4)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Style.shared.textColor(.body).source())
                
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.top, .extraLarge)
        .padding(.horizontal, .medium)
        
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
            titleColor: Style.shared.textColor(.button),
            action: {
                self.viewModel.navigateToSignUp()
            })
        
    }
    
    var loginButton: some View {
        
        CommonButton(
            style: .outline(lineWidth: 3),
            title: "Login",
            titleColor: Style.shared.accent,
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

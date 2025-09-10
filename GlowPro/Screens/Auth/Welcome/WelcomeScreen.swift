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
        .preferredColorScheme(.light)
        
    }
    
    var content: some View {
        
        VStack(spacing: Style.shared.spacing(.none)) {
            
            Image(.illustrationWelcome)
                .resizable()
                .frame(height: UIScreen.main.bounds.height / 1.95)
            
            VStack(spacing: Style.shared.spacing(.large)) {
                
                Text("GlowPro")
                    .appFont(with: .BILLBOARD_1)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Style.shared.textColor(.title).source())
                
                Text("Secure records, treatment tracking, and before & after results, all in one place.")
                    .appFont(with: .BODY_4)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Style.shared.textColor(.body).source())
                    .padding(.horizontal, .custom(48))
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.top, .custom(48))
            .background(Style.shared.background(.primary).source())
//            .background {
//                
//                LinearGradient(
//                    colors: [
//                        Style.shared.accent.asColor!.opacity(1),
//                        Color(hex: "#A9D0B5"),
////                        Color(hex: "#A9D0B5").opacity(0.01)
//                    ],
//                    startPoint: .top,
//                    endPoint: .bottom
//                )
//                
//            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .ignoresSafeArea()
        
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

//
//  WelcomeScreen.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 5/16/25.
//

import SwiftUI

struct WelcomeScreen: GPView {
    
    @StateObject var viewModel: WelcomeViewModel
    @State private var navigationService = NavigationService()
        
    var body: some View {
        
        NavigationStack(path: self.$navigationService.routes) {
            
            ZStack(alignment: .center) {
                
                Style.shared.background(.tertiary)
                    .view()
                    .ignoresSafeArea()
                
                VStack(spacing: Style.shared.spacing(.custom(64))) {
                    
                    content
                    
                    Spacer(minLength: 0)
                    
                }
                .padding(.top, .extraLarge)
                                
            }
            .safeAreaInset(edge: .bottom) {
                
                VStack(spacing: 16) {
                    
                    signUpButton
                    loginButton
                    
                }
                .padding(.horizontal, 32)
                .customSafeAreaPadding()
                
            }
            
            .onFirstAppear {
                
                self.viewModel
                    .track()
                
                self.viewModel
                    .setup(navigationService: self.navigationService)
                
            }
            
            .withNavigationDestination()
            .withSheetDestination(self.$navigationService.sheet)
            .withFullScreenCover(self.$navigationService.fullScreenCover)

        }
        .environment(self.navigationService)
        
    }
    
    var content: some View {
        
        VStack {
            
            Text("Welcome To\nGrimoire")
                .appFont(with: .HEADER_H1)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
            
        }
        .frame(maxWidth: .infinity)
        
    }
    
    var signUpButton: some View {
        
        CommonButton(
            title: "Sign Up",
            action: {
                self.viewModel.navigateToSignUp()
            })
        
    }
    
    var loginButton: some View {
        
        CommonButton(
            title: "Login",
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

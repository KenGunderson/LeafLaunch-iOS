//
//  WelcomeScreen.swift
//  GlowPro 
//
//  Created by Sako Hovaguimian on 5/16/25.
//

import SwiftUI

struct WelcomeScreen: GPView {
    
    @StateObject var viewModel: WelcomeViewModel
    @Environment(NavigationService.self) private var navigationService
    
    @State private var footerSize: CGSize = .zero
        
    var body: some View {
        
        AppRootView(
            navigationService: Bindable(self.navigationService),
            alertService: nil // // Setting Alert Service as Nill so we still use our current AlertService from Root
        ) {
            
            content
                .safeAreaInset(edge: .bottom) {
                    footer
                }
            
                .onFirstAppear {
                    
                    self.viewModel
                        .track()
                    
                }
            
        }
        .preferredColorScheme(.light)
        .task {
            
            self.viewModel
                .setup(navigationService: self.navigationService)
            
        }
        
    }
    
    var content: some View {
        
        VStack(spacing: Style.shared.spacing(.none)) {
            
            Image(.illustrationWelcome)
                .resizable()
                .frame(height: UIScreen.main.bounds.height / 1.95)
            
            VStack(spacing: Style.shared.spacing(.large)) {
                
                Image(.illustrationLogo)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
                
                Text("Secure records, treatment tracking, and before & after results, all in one place.")
                    .appFont(with: .BODY_4)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Style.shared.textColor(.body).source())
                    .padding(.horizontal, .custom(48))
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .background(Style.shared.background(.primary).source())
            .padding(.bottom, self.footerSize.height + Style.shared.spacing(.medium))
            
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
        .onGeometryChange(for: CGSize.self) { proxy in
            return proxy.size
        } action: { newValue in
            self.footerSize = newValue
        }

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
    .withMockServices(withNaivgationService: false)
    
}

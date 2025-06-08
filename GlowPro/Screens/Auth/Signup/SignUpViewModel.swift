//
//  SignUpViewModel.swift
//  GlowPro 
//
//  Created by Sako Hovaguimian on 5/16/25.
//

import SwiftUI
import Combine
import AuthenticationServices

final class SignUpViewModel: ViewModel {
    
    private let analyticsService: AnalyticsServiceProtocol
    private let authService: AuthServiceProtocol
    private let viewLifecycleService: ViewLifecycleServiceProtocol
    private let environmentService: EnvironmentServiceProtocol
    
    private var navigationService: NavigationService?
    private var cancelBag: CancelBag!
    private let logger = GPLogger.viewModel(.signUp)
    
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    
    @Published private var currentNonce: String?
    @Published var error: Error?
    
    var isButtonEnabled: Bool {
        
        return (
            self.email.count > 3 &&
            self.password.count >= 6 &&
            self.name.count >= 3
        )
        
    }
    
    init(analyticsService: AnalyticsServiceProtocol,
         authService: AuthServiceProtocol,
         viewLifecycleService: ViewLifecycleServiceProtocol,
         environmentService: EnvironmentServiceProtocol) {
        
        self.analyticsService = analyticsService
        self.authService = authService
        self.viewLifecycleService = viewLifecycleService
        self.environmentService = environmentService
        
        self.logger.logInit()
        
        bindSubscribers()
        
    }
    
    deinit {
        
        self.logger
            .logDeinit()
        
    }
    
    func set(nonce: String) {
        self.currentNonce = nonce
    }
    
    @MainActor
    func handleAppleAuthoriziation(result: Result<ASAuthorization, any Error>) {
        
        switch result {
        case .success(let authorization):
            
            Task {
                await handleAppleLogin(authorization: authorization)
            }
            
        case .failure(let error): self.error = error
        }
        
    }
    
    @MainActor
    func handleSignUp() {
        
        self.analyticsService
            .track(.onboarding(.signupIntent))
        
        Task {
            
            do {
                
                try await self.authService.signup(
                    name: self.name.capitalized,
                    email: self.email,
                    password: self.password
                )
                
                await MainActor.run { [weak self] in
                    
                    self?.navigationService?
                        .popToRoot()
                    
                }
                
            }
            catch(let error) {
                
                await MainActor.run { [weak self] in
                    self?.error = error
                }
                
            }
            
        }
        
    }
    
    func dismiss() {
        self.navigationService?.pop()
    }
    
    func setup(navigationService: NavigationService) {
        self.navigationService = navigationService
    }
    
    private func bindSubscribers() {
        self.cancelBag = CancelBag()
    }
    
    @MainActor
    private func handleAppleLogin(authorization: ASAuthorization) async {
        
        self.analyticsService
            .track(.onboarding(.appleSignupIntent))
        
        do {
            
            try await self.authService.handleAppleSignupOrLogin(
                currentNonce: self.currentNonce,
                authorization: authorization,
                isLogin: false
            )
            
            await MainActor.run { [weak self] in
                self?.dismiss()
            }
            
        }
        catch(let error) {
            self.error = error
        }
        
    }
    
}

extension SignUpViewModel {
    
    func track() {
        self.analyticsService.track(screen: .onboarding(.signUp))
    }
    
}

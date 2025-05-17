//
//  LoginViewModel.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 5/16/25.
//

import SwiftUI
import Combine
import AuthenticationServices

final class LoginViewModel: ViewModel {
    
    private let analyticsService: AnalyticsServiceProtocol
    private let authService: AuthServiceProtocol
    private let viewLifecycleService: ViewLifecycleServiceProtocol
    private let environmentService: EnvironmentServiceProtocol
    
    private var navigationService: NavigationService?
    private var cancelBag: CancelBag!
    private let logger = GrimoireLogger.viewModel(.login)
    
    @Published var email: String = ""
    @Published var password: String = ""
    
    @Published private(set) var currentNonce: String?
    
    @Published var shouldPresentForgotPassword = false
    @Published var error: Error?
    
    var isButtonEnabled: Bool {
        
        return (
            self.email.count > 3 &&
            self.password.count >= 6
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
    
    func dismiss() {
        self.navigationService?.pop()
    }
    
    func handleForgotPassword() {
        
        self.analyticsService.track(.onboarding(.forgotPasswordIntent))
        self.shouldPresentForgotPassword = true
        
    }
    
    func setup(navigationService: NavigationService) {
        self.navigationService = navigationService
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
    func handleForgetPassword(email: String) {
        
        Task {
            
            do {
                
                try await self.authService.resetPassword(email: email)
                
                self.analyticsService
                    .track(.onboarding(.forgotPassword(email: email)))
                
            }
            catch(let error) {
                
                await MainActor.run { [weak self] in
                    self?.error = error
                }
                
            }
            
        }
        
    }
    
    @MainActor
    func handleLogin() {
        
        self.analyticsService
            .track(.onboarding(.loginIntent))
            
        Task {
            
            do {
                
                try await self.authService.login(
                    email: self.email,
                    password: self.password
                )
                
                await MainActor.run { [weak self] in
                    self?.dismiss()
                }
                
            }
            catch(let error) {
                
                await MainActor.run { [weak self] in
                    self?.error = error
                }
                
            }
            
        }
        
    }
    
    private func bindSubscribers() {
        self.cancelBag = CancelBag()
    }
    
    @MainActor
    private func handleAppleLogin(authorization: ASAuthorization) async {
        
        self.analyticsService
            .track(.onboarding(.appleLoginIntent))
        
        do {
            
            try await self.authService.handleAppleSignupOrLogin(
                currentNonce: self.currentNonce,
                authorization: authorization,
                isLogin: true
            )
            
            dismiss()
            
        }
        catch(let error) {
            
            await MainActor.run { [weak self] in
                self?.error = error
            }
            
        }
        
    }
    
}

extension LoginViewModel {
    
    func track() {
        self.analyticsService.track(screen: .onboarding(.login))
    }
    
}

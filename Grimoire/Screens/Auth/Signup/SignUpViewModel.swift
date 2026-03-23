//
//  SignUpViewModel.swift
//  Grimoire 
//
//  Created by Sako Hovaguimian on 5/16/25.
//

import SwiftUI
import Combine
import AuthenticationServices

final class SignUpViewModel: ViewModel {
    
    internal let loggerName: String = "SIGN_UP_VIEW_MODEL"
    internal let loggerEmoji: String = "👤"
    
    private let alertService: AlertServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let authService: AuthServiceProtocol
    private let viewLifecycleService: ViewLifecycleServiceProtocol
    private let environmentService: EnvironmentServiceProtocol
    
    private weak var navigationService: NavigationService?
    private var cancelBag: CancelBag!
    private var appleAuthorizationTask: Task<Void, Never>?
    private var signUpTask: Task<Void, Never>?
    
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var agreedToTerms: Bool = false
    
    @Published private var currentNonce: String?
    @Published var error: Error?
        
    var isButtonEnabled: Bool {
        
        return (
            self.email.count > 3 &&
            self.password.count >= 6 &&
            self.firstName.count >= 2 &&
            self.lastName.count >= 2
        )
        
    }
    
    init(alertService: AlertServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         authService: AuthServiceProtocol,
         viewLifecycleService: ViewLifecycleServiceProtocol,
         environmentService: EnvironmentServiceProtocol) {
        
        self.alertService = alertService
        self.analyticsService = analyticsService
        self.authService = authService
        self.viewLifecycleService = viewLifecycleService
        self.environmentService = environmentService
        
        self.logInit()
        
        bindSubscribers()
        
    }
    
    isolated deinit {
        cancelTasks()
        self.logDeinit()
    }
    
    func set(nonce: String) {
        self.currentNonce = nonce
    }
    
    @MainActor
    func handleAppleAuthoriziation(result: Result<ASAuthorization, any Error>) {
        
        switch result {
        case .success(let authorization):
            
            self.appleAuthorizationTask?.cancel()
            
            let analyticsService = self.analyticsService
            let authService = self.authService
            let currentNonce = self.currentNonce
            
            self.appleAuthorizationTask = Task { [weak self] in
                
                analyticsService
                    .track(.onboarding(.appleSignupIntent))
                
                do {
                    
                    try await authService.handleAppleSignupOrLogin(
                        currentNonce: currentNonce,
                        authorization: authorization,
                        isLogin: false
                    )
                    
                    guard !Task.isCancelled else { return }
                    self?.dismiss()
                    
                }
                catch(let error) {
                    
                    guard !Task.isCancelled else { return }
                    self?.error = error
                    
                }
                
            }
            
        case .failure(let error): self.error = error
        }
        
    }
    
    @MainActor
    func handleSignUp() {
        
        self.analyticsService
            .track(.onboarding(.signupIntent))
        
        self.signUpTask?.cancel()
        
        let authService = self.authService
        let firstName = self.firstName.capitalized
        let lastName = self.lastName.capitalized
        let email = self.email
        let password = self.password
        
        self.signUpTask = Task { [weak self] in
            
            do {
                
                try await authService.signup(
                    firstName: firstName,
                    lastName: lastName,
                    email: email,
                    password: password
                )
                
                guard !Task.isCancelled else { return }
                
                self?.navigationService?
                    .popToRoot()
                
            }
            catch(let error) {
                
                guard !Task.isCancelled else { return }
                self?.error = error
                
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
    
    private func cancelTasks() {
        
        self.appleAuthorizationTask?.cancel()
        self.signUpTask?.cancel()
        
    }
    
}

extension SignUpViewModel {
    
    func track() {
        self.analyticsService.track(screen: .onboarding(.signUp))
    }
    
}

//
//  DevImpersonateViewModel.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 11/4/24.
//

import SwiftUI

final class DevImpersonateViewModel: ViewModel {
    
    private(set) var analyticsService: AnalyticsServiceProtocol
    private let impersonateService: ImpersonateServiceProtocol
    private let alertService: AlertServiceProtocol
    private let viewLifecycleService: ViewLifecycleServiceProtocol
    private let environmentService: EnvironmentServiceProtocol
    
    private var navigationService: NavigationService?
    private var cancelBag: CancelBag!
    
    @Published var userToImpersonateEmail: String = ""
    @Published var isImpersonating: Bool?

    init(analyticsService: AnalyticsServiceProtocol,
         impersonateService: ImpersonateServiceProtocol,
         viewLifecycleService: ViewLifecycleServiceProtocol,
         alertService: AlertServiceProtocol,
         environmentService: EnvironmentServiceProtocol) {
        
        self.analyticsService = analyticsService
        self.impersonateService = impersonateService
        self.alertService = alertService
        self.viewLifecycleService = viewLifecycleService
        self.environmentService = environmentService
        
        bindSubscribers()
                
    }
    
    func setup(navigationService: NavigationService) {
        self.navigationService = navigationService
    }
    
    func dismiss() {
        
        self.navigationService?
            .pop()
        
    }
    
    func impersonateOrRevert() {
        
        guard let isImpersonating else { return }
        
        if !isImpersonating {
            impersonate()
        } else {
            revert()
        }
        
    }
    
    private func impersonate() {
        
        guard !self.userToImpersonateEmail.isEmpty else { return }
        
        let loadingAlert = Alert(.loadingIndicator(
            .init(loadStyle: .progressView(title: "Impersonating"))
        ))
        
        Task {
            
            self.alertService
                .showAlert(loadingAlert)
            
            defer {
                
                self.alertService
                    .dismissAlert(loadingAlert)
                
            }
            
            do {
                
                try await self.impersonateService
                    .impersonateUser(email: userToImpersonateEmail)
                
            }
            catch {
                presentError(error)
            }
            
        }
        
    }
    
    private func revert() {
        
        let loadingAlert = Alert(.loadingIndicator(
            .init(loadStyle: .progressView(title: "Impersonating"))
        ))
        
        Task {
            
            self.alertService
                .showAlert(loadingAlert)
            
            defer {
                
                self.alertService
                    .dismissAlert(loadingAlert)
                
            }
            
            do {
                try await self.impersonateService.revert()
            }
            catch {
                presentError(error)
            }
            
        }
        
    }
    
    func bindSubscribers() {
        
        self.cancelBag = CancelBag()
        
        self.impersonateService
            .impersonatedUserPublisher
            .receiveOnMain()
            .sink { [weak self] impersonatedUser in
                
                self?.isImpersonating = (impersonatedUser != nil)
                self?.userToImpersonateEmail = impersonatedUser?.email ?? ""
                
            }
            .store(in: &self.cancelBag)
        
    }
    
    private func presentError(_ error: Error) {
        
        self.alertService
            .showAlert(
                .init(
                    .appAlert(
                        .error(
                            message: error.getMessageForError(),
                            action: {}
                        )
                    )
                )
            )
        
    }
    
}

extension DevImpersonateViewModel {
    
    func track() {
        self.analyticsService.track(screen: .devSettings(.impersonate))
    }
    
}

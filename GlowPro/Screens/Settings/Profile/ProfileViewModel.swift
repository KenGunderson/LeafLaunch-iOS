//
//  ProfileViewModel.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 10/28/25.
//

import SwiftUI
import Combine

final class ProfileViewModel: ViewModel {
    
    internal let loggerName: String = "PROFILE_VIEW_MODEL"
    internal let loggerEmoji: String = "⚙️"
    
    private let apiService: APIServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let authService: AuthServiceProtocol
    private let alertService: AlertServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol
    private let viewLifecycleService: ViewLifecycleServiceProtocol
    private let environmentService: EnvironmentServiceProtocol
    private var navigationService: NavigationService?
    
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var dateOfBirth: Date = .now
    
    @Published private(set) var isLoading: Bool = true
    
    var isSubmitButtonEnabled: Bool {
        return isSaveButtonEnabled()
    }
    
    private(set) var businessId: String?
    private var cancelBag: CancelBag!
        
    init(apiService: APIServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         authService: AuthServiceProtocol,
         alertService: AlertServiceProtocol,
         userDefaultsService: UserDefaultsServiceProtocol,
         viewLifecycleService: ViewLifecycleServiceProtocol,
         environmentService: EnvironmentServiceProtocol) {
        
        self.apiService = apiService
        self.analyticsService = analyticsService
        self.authService = authService
        self.alertService = alertService
        self.userDefaultsService = userDefaultsService
        self.viewLifecycleService = viewLifecycleService
        self.environmentService = environmentService
        
        bindSubscribers()
        self.logInit()
        
    }
    
    deinit {
        self.logDeinit()
    }
    
    func setup(navigationService: NavigationService) {
        self.navigationService = navigationService
    }
    
    func loadData() {
        
        guard let user = self.authService.currentUser else { return }
        
        self.isLoading = true
        
        self.alertService
            .showAlert(.init(.simpleLoadingIndicator))

        Task {
            
            do {
                
                let user = try await self.apiService
                    .getUser(id: user.id)
                
                await MainActor.run { [weak self] in
                    
                    self?.firstName = user.firstName
                    self?.lastName = user.lastName
                    self?.dateOfBirth = user.birthday ?? .now
                    
                    self?.isLoading = false
                    
                }
                
            }
            catch {
                
                self.alertService.showAlert(.init(
                    .appAlert(
                        .error(
                            message: Constants.Message.errorMessage("user"),
                            action: {
                                
                                self.navigationService?
                                    .popWithDelay()
                                
                            })
                    ))
                )
                
            }
            
            self.alertService
                .dismissLoadingIndicator()
            
        }
        
    }
    
    func dismiss() {
        
        self.navigationService?
            .pop()
        
    }
    
    func update() {
        
        guard let user = self.authService.currentUser else { return }
                
        self.alertService
            .showAlert(.init(.simpleLoadingIndicator))

        Task {
            
            do {
                
                let isValidDateOfBirth = !self.dateOfBirth.isToday
                let dateOfBirth = isValidDateOfBirth ? self.dateOfBirth.ISO8601Format() : nil
                
                let updatedUser = GPUser(
                    id: user.id,
                    firstName: self.firstName,
                    lastName: self.lastName,
                    email: user.email,
                    phoneNumber: user.phoneNumber,
                    externalId: user.externalId,
                    birthday: dateOfBirth,
                    imageURL: user.imageURL
                )
                
                try await self.apiService
                    .updateUser(user: updatedUser)
                
                try await self.authService
                    .reloadUser()
                
                self.alertService
                    .showAlert(.init(.appAlert(.success(
                        message: "Profile updated successfully.",
                        action: {
                            
                            self.navigationService?
                                .popWithDelay()
                            
                        }
                        
                    ))))
                
            }
            catch {
                
                self.alertService.showAlert(.init(
                    .appAlert(
                        .error(
                            message: Constants.Message.errorMessage("user"),
                            action: {}
                        )
                    ))
                )
                
            }
            
            self.alertService
                .dismissLoadingIndicator()
            
        }
        
    }
    
    private func isSaveButtonEnabled() -> Bool {
        
        var hasFirstNameOrLastNameChanged: Bool {
            
            let firstName = self.authService.currentUser?.firstName ?? ""
            let lastName = self.authService.currentUser?.lastName ?? ""
            
            return (firstName != self.firstName) || (lastName != self.lastName)
            
        }
        
        var hasDateChanged: Bool {
            
            let defaultDate = Date().formatted(date: .complete, time: .omitted)
            let dateOfBirth = self.authService.currentUser?.birthday?.formatted(date: .complete, time: .omitted) ?? defaultDate
            return dateOfBirth != self.dateOfBirth.formatted(date: .complete, time: .omitted)
            
        }
        
        var hasUserInfoChanged: Bool {
            return hasFirstNameOrLastNameChanged || hasDateChanged
        }
        
        return (
            !self.firstName.isEmpty &&
            !self.lastName.isEmpty &&
            hasUserInfoChanged
        )
        
    }

    private func bindSubscribers() {
        self.cancelBag = CancelBag()
    }
    
}

extension ProfileViewModel {
    
    func track() {
        self.analyticsService.track(screen: .settings(.profile))
    }
    
}

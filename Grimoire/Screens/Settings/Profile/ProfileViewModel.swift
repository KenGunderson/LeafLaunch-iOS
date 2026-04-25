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
    private weak var navigationService: NavigationService?
    
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var email: String = ""
    @Published var dateOfBirth: Date = .now
    
    @Published private(set) var isLoading: Bool = true
    
    var isSubmitButtonEnabled: Bool {
        return isSaveButtonEnabled()
    }
    
    private(set) var businessId: String?
    private var cancelBag: CancelBag!
    private var loadDataTask: Task<Void, Never>?
    private var updateTask: Task<Void, Never>?
        
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
        
        self.logInit()
        
    }
    
    isolated deinit {
        
        cancelTasks()
        self.logDeinit()
        
    }
    
    func setup(navigationService: NavigationService) {
        self.navigationService = navigationService
    }

    func handleFirstAppear() {
        
        track()
        bindSubscribers()
        
    }
    
    func loadData() {
        
        guard let user = self.authService.currentUser else { return }
        
        self.loadDataTask?.cancel()
        
        self.isLoading = true
        
        self.alertService
            .showAlert(.init(.simpleLoadingIndicator))
        
        let alertService = self.alertService
        let apiService = self.apiService
        let userId = user.id
        
        self.loadDataTask = Task { [weak self] in
            
            defer {
                
                alertService
                    .dismissLoadingIndicator()
                
            }
            
            do {
                
                let user = try await apiService
                    .getUser(id: userId)
                
                guard !Task.isCancelled else { return }
                
                self?.firstName = user.firstName
                self?.lastName = user.lastName
                self?.email = user.email
                self?.dateOfBirth = user.dateOfBirth ?? .now
                
                self?.isLoading = false
                
            }
            catch {
                
                guard !Task.isCancelled else { return }
                
                alertService.showAlert(.init(
                    .appAlert(
                        .error(
                            message: Constants.Message.errorMessage("user"),
                            action: { [weak self] in
                                
                                self?.navigationService?
                                    .popWithDelay()
                                
                            })
                    ))
                )
                
            }
                        
        }
        
    }
    
    func dismiss() {
        
        self.navigationService?
            .pop()
        
    }
    
    func update() {
        
        guard let user = self.authService.currentUser else { return }
        
        self.updateTask?.cancel()
                
        self.alertService
            .showAlert(.init(.simpleLoadingIndicator))
        
        let alertService = self.alertService
        let apiService = self.apiService
        let authService = self.authService
        let firstName = self.firstName
        let lastName = self.lastName
        let dateOfBirthValue = self.dateOfBirth
        
        self.updateTask = Task { [weak self] in
            
            defer {
                
                alertService
                    .dismissLoadingIndicator()
                
            }
            
            do {
                
                let isValidDateOfBirth = !dateOfBirthValue.isToday
                let dateOfBirth = isValidDateOfBirth ? dateOfBirthValue.ISO8601Format() : nil
                
                let updatedUser = GPUser(
                    id: user.id,
                    firstName: firstName,
                    lastName: lastName,
                    email: user.email,
                    phoneNumber: user.phoneNumber,
                    externalId: user.externalId,
                    dateOfBirth: dateOfBirth,
                    imageURL: user.imageURL
                )
                
                try await apiService
                    .updateUser(user: updatedUser)
                
                try await authService
                    .reloadUser()
                
                guard !Task.isCancelled else { return }
                
                alertService
                    .showAlert(.init(.appAlert(.success(
                        message: "Profile updated successfully.",
                        action: { [weak self] in
                            
                            self?.navigationService?
                                .popWithDelay()
                            
                        }
                        
                    ))))
                
            }
            catch {
                
                guard !Task.isCancelled else { return }
                
                alertService.showAlert(.init(
                    .appAlert(
                        .error(
                            message: Constants.Message.errorMessage("user"),
                            action: {}
                        )
                    ))
                )
                
            }
                        
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
            let dateOfBirth = self.authService.currentUser?.dateOfBirth?.formatted(date: .complete, time: .omitted) ?? defaultDate
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
    
    private func cancelTasks() {
        
        self.loadDataTask?.cancel()
        self.updateTask?.cancel()
        
    }
    
}

extension ProfileViewModel {
    
    func track() {
        self.analyticsService.track(screen: .settings(.profile))
    }
    
}

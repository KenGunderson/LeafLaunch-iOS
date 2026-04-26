//
//  AuthService.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 7/13/24.
//

import SwiftUI
import AuthenticationServices
import Combine
import FirebaseAuth

final class AuthService: AuthServiceProtocol {
    
    internal let loggerName: String = "AUTH_SERVICE"
    internal let loggerEmoji: String = "🪪"
    
    private let firebaseService: FirebaseServiceProtocol
    private let apiService: APIServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol
    
    @Published private(set) var currentUser: GPUser?
    var currentUserPublisher: AnyPublisher<GPUser?, Never> {
        return self.$currentUser.eraseToAnyPublisher()
    }
    
    private(set) var onInitialLoadCompleted = CurrentValueSubject<Bool, Never>(false)
    private(set) var onError = CurrentValueSubject<Error?, Never>(nil)
    
    var cancelBag: CancelBag!
    private var logoutTask: Task<Void, Never>?
    private var initialUserLoadTask: Task<Void, Never>?
    
    init(firebaseService: FirebaseServiceProtocol,
         apiService: APIServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         userDefaultsService: UserDefaultsServiceProtocol) {
        
        self.firebaseService = firebaseService
        self.apiService = apiService
        self.analyticsService = analyticsService
        self.userDefaultsService = userDefaultsService
        
        bindSubscribers()
        self.logInit()

    }
    
    isolated deinit {
        
        cancelTasks()
        self.logDeinit()
        
    }
    
    @MainActor
    func signup(firstName: String,
                lastName: String,
                email: String,
                password: String) async throws {
        
        do {
            
            try await self.firebaseService.signup(
                email: email,
                password: password
            )
            
            let _ = try await self.apiService
                .createUser(user: .init(
                    id: "",
                    firstName: firstName.capitalized.trimmed(),
                    lastName: lastName.capitalized.trimmed(),
                    email: email,
                    externalId: self.firebaseService.user?.uid ?? "",
                    dateOfBirth: nil,
                    imageURL: nil
                ))
            
            try await fetchUserInfoWithToken()
            
        }
        catch {
            
            if self.currentUser != nil {
                self.logoutDetached()
            }
                        
            self.logError(
                title: "Sign Up Error",
                message: error.getMessageForError()
            )
            
            throw error
            
        }
        
    }
    
    @MainActor
    func login(email: String,
               password: String) async throws {
        
        do {
            
            try await self.firebaseService.login(
                email: email,
                password: password
            )
            
            try await fetchUserInfoWithToken()
            
        }
        catch {
            
            if self.currentUser != nil {
                self.logoutDetached()
            }
                        
            self.logError(
                title: "Login Error",
                message: error.getMessageForError()
            )
            
            throw error
            
        }
        
    }

    @MainActor
    func updateEmail(_ email: String) async throws {
        
        do {
            
            try await self.firebaseService.updateEmail(newEmail: email)
            
        }
        catch {
            
            self.logError(
                title: "Update Email Error",
                message: error.getMessageForError()
            )
            
            throw error
            
        }
        
    }
    
    @MainActor
    func fetchUserInfoWithToken() async throws {
        
        do {
            
            try await self.firebaseService
                .getAccessTokenForCurrentUser()
                        
            let user = try await self.apiService
                .getUserProfile()
            
            self.currentUser = user
            
            if self.analyticsService.currentUserId.value == nil {
                self.analyticsService.identifyUser(user.id)
            }
            
        }
        catch {
            
            self.logError(
                title: "User Info Error",
                message: error.getMessageForError()
            )
            
            throw error
            
        }
        
    }
    
    @MainActor
    func reloadUser() async throws {
        
        do {
            
            let user = try await self.apiService
                .getUserProfile()
            
            self.currentUser = user
            
        }
        catch {
            
            self.logError(
                title: "Reload User Error",
                message: error.getMessageForError()
            )
            
            throw error
            
        }
        
    }
    
    @MainActor
    func logout() async throws {
        
        do {
            
            globalTabBarNavigationService?.resetPathItems()
            try self.firebaseService.logout()
            await self.userDefaultsService.logout()
            self.analyticsService.logout()
            self.currentUser = nil
            
        }
        catch {
            
            self.logError(
                title: "Logout Error",
                message: error.getMessageForError()
            )
            
            throw error
            
        }
        
    }
    
    func logoutDetached() {
        
        self.logoutTask?.cancel()
        
        self.logoutTask = Task { [weak self] in
            
            do {
                try await self?.logout()
            }
            catch {
                guard !Task.isCancelled else { return }
            }
            
        }
        
    }
    
    @MainActor
    func deleteUser() async throws {
        
        guard let currentUser = self.currentUser else { return }
        
        do {
            
            try await self.apiService
                .deleteUser(user: currentUser)
            
            try self.firebaseService.logout()
            await self.userDefaultsService.logout()
            
            self.analyticsService.logout()
            self.currentUser = nil
            
        }
        catch {
            
            self.logError(
                title: "Delete User Error",
                message: error.getMessageForError()
            )
            
            throw error
            
        }
        
    }
        
    @MainActor
    func handleAppleSignupOrLogin(currentNonce: String?,
                                  authorization: ASAuthorization,
                                  isLogin: Bool) async throws {
        
        let authResult: (name: String?,
                         email: String?,
                         idTokenString: String,
                         nonce: String) = try await withCheckedThrowingContinuation { continuation in
            
            self.firebaseService.handleAppleSignupOrLogin(
                currentNonce: currentNonce,
                authorization: authorization
            ) { name, email, idTokenString, nonce, error in
                
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                
                continuation.resume(returning: (
                    name: name,
                    email: email,
                    idTokenString: idTokenString,
                    nonce: nonce
                ))
                
            }
            
        }
        
        try await self.firebaseService.login(
            token: authResult.idTokenString,
            nonce: authResult.nonce
        )
        
        if let name = authResult.name,
           let email = authResult.email {
            
            let user = try await self.apiService
                .createUser(user: .init(
                    id: "",
                    firstName: name.firstName,
                    lastName: name.lastName,
                    email: email,
                    externalId: self.firebaseService.user?.uid ?? "",
                    dateOfBirth: nil,
                    imageURL: nil
                ))
            
            self.currentUser = user
            
        }
        else {
            
            let user = try await self.apiService
                .getUserProfile()
            
            self.currentUser = user
            
        }
        
    }
    
    @MainActor
    func resetPassword(email: String) async throws {
        
        do {
            try await self.firebaseService.resetPassword(email: email)
        }
        catch(let error) {
            
            self.logError(
                title: "Reset Password Error",
                message: error.getMessageForError()
            )
            
            throw error
            
        }
        
    }
    
    // MARK: - Private
    
    private func bindSubscribers() {
        
        self.cancelBag = CancelBag()
        
        self.firebaseService
            .userPublisher
            .receiveOnMain()
            .sink { [weak self] user in
                
                guard let self else { return }
                guard let user else { return }
                guard !self.firebaseService.isSignUpContext else { return }
                
                loadInitialUser(user)
                
            }
            .store(in: &self.cancelBag)
        
    }
    
    private func loadInitialUser(_ user: User) {
        
        self.initialUserLoadTask?.cancel()
        
        self.initialUserLoadTask = Task { [weak self] in
            
            guard let self else { return }
            
            defer {
                self.onInitialLoadCompleted.send(true)
            }
            
            guard let _ = self.firebaseService.user else { return }

            do {
                try await fetchUserInfoWithToken()
            }
            catch {
                
                self.logError(
                    title: "Load Initial User Error",
                    message: error.getMessageForError()
                )
                
                // TODO: - This causes two errors because the throw goes to LoginViewModel / SignupViewModel
                // But this OnError presents on the RootViewModel. We need a way to know if this endpoint failed before or after the user has signed in. If old sign in then this onError should be good.
                
                if self.onInitialLoadCompleted.value {
                    self.onError.send(error)
                }
                
            }
            
        }
        
    }
    
    private func cancelTasks() {
        
        self.logoutTask?.cancel()
        self.initialUserLoadTask?.cancel()
        
    }
    
}

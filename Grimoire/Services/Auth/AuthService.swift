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
    
    private let logger = GrimoireLogger.service(.auth)
    var cancelBag: CancelBag!
    
    init(firebaseService: FirebaseServiceProtocol,
         apiService: APIServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         userDefaultsService: UserDefaultsServiceProtocol) {
        
        self.firebaseService = firebaseService
        self.apiService = apiService
        self.analyticsService = analyticsService
        self.userDefaultsService = userDefaultsService
        
        bindSubscribers()
        
        self.logger.logInit()

    }
    
    deinit {
        
        self.logger
            .logDeinit()
        
    }
    
    @MainActor
    func signup(name: String,
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
                    name: name.capitalized,
                    email: email,
                    externalId: self.firebaseService.user?.uid ?? "",
                    birthday: nil,
                    gender: nil,
                    imageURL: nil
                ))
            
            try await fetchUserInfoWithToken()
            
        }
        catch {
            
            self.logger.error(
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
            
            self.logger.error(
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
            
            self.logger.error(
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
            
            self.logger.error(
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
            
            self.logger.error(
                title: "Reload User Error",
                message: error.getMessageForError()
            )
            
            throw error
            
        }
        
    }
    
    @MainActor
    func logout() async throws {
        
        do {
            
            try self.firebaseService.logout()
            await self.userDefaultsService.logout()
            self.analyticsService.logout()
            self.currentUser = nil
            
        }
        catch {
            
            self.logger.error(
                title: "Logout Error",
                message: error.getMessageForError()
            )
            
            throw error
            
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
            
            self.logger.error(
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
        
        return try await withCheckedThrowingContinuation { continuation in
            
            self.firebaseService.handleAppleSignupOrLogin(
                currentNonce: currentNonce,
                authorization: authorization,
                completion: { name, email, idTokenString, nonce, error in
                    
                    if let error = error {
                        continuation.resume(throwing: error)
                    }
                    
                    Task {
                        
                        do {
                            
                            try await self.firebaseService.login(
                                token: idTokenString,
                                nonce: nonce
                            )
                            
                            if let name,
                               let email {
                                
                                // Create user
                                
                                let user = try await self.apiService
                                    .createUser(user: .init(
                                        id: "",
                                        name: name,
                                        email: email,
                                        externalId: self.firebaseService.user?.uid ?? "",
                                        birthday: nil,
                                        gender: nil,
                                        imageURL: nil
                                    ))
                                
                                DispatchQueue.main.async {
                                    self.currentUser = user
                                }
                                
                                continuation.resume()
                                
                            }
                            else {
                                
                                // Get Profile
                                                                
                                let user = try await self.apiService
                                    .getUserProfile()
                                
                                DispatchQueue.main.async {
                                    self.currentUser = user
                                }
                                
                                continuation.resume()
                                
                            }
                            
                        }
                        catch {
                            continuation.resume(throwing: error)
                        }
                        
                    }
                    
                })
            
        }
        
    }
    
    @MainActor
    func resetPassword(email: String) async throws {
        
        do {
            try await self.firebaseService.resetPassword(email: email)
        }
        catch(let error) {
            
            self.logger.error(
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
                
                loadInitialUser(user)
                
            }
            .store(in: &self.cancelBag)
        
    }
    
    private func loadInitialUser(_ user: User) {
        
        Task {
            
            defer {
                self.onInitialLoadCompleted.send(true)
            }
            
            guard let _ = self.firebaseService.user else { return }

            do {
                try await fetchUserInfoWithToken()
            }
            catch {
                
                self.logger.error(
                    title: "Load Initial User Error",
                    message: error.getMessageForError()
                )
                
                // TODO: - This causes two errors because the throw goes to LoginViewModel / SignupViewModel
                // But this OnError presents on the RootViewModel. We need a way to know if this endpoint failed before or after the user has signed in. If old sign in then this onError should be good. 
                self.onError.send(error)
                throw error
                
            }
            
        }
        
    }
    
}

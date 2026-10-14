//
//  AuthService.swift
//  LeafLaunch
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

    @Published private(set) var currentUser: LLUser?
    var currentUserPublisher: AnyPublisher<LLUser?, Never> {
        return self.$currentUser.eraseToAnyPublisher()
    }

    private(set) var onInitialLoadCompleted = CurrentValueSubject<Bool, Never>(false)
    private(set) var onError = CurrentValueSubject<Error?, Never>(nil)

    var cancelBag: CancelBag!
    private var logoutTask: Task<Void, Never>?
    private var initialUserLoadTask: Task<Void, Never>?
    private var initialUserLoadId: UUID?

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

        defer {
            self.firebaseService.clearAuthContext()
        }

        guard let locationId = self.userDefaultsService.lastSelectedLocationId else {
            throw APIError.serverError(statusCode: 400, errorMessage: "Choose a store before creating an account.")
        }

        do {

            try await self.firebaseService.signup(
                email: email,
                password: password
            )

            self.apiService.accessToken = self.firebaseService.currentAccessToken

            _ = try await self.apiService.registerCustomerAccount(
                locationId: locationId,
                displayName: "\(firstName.trimmed()) \(lastName.trimmed())".trimmed()
            )
            try Task.checkCancellation()

            try await fetchUserInfoWithToken()

        }
        catch {

            if self.currentUser != nil || self.firebaseService.user != nil {
                try? await self.logout()
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

        defer {
            self.firebaseService.clearAuthContext()
        }

        do {

            try await self.firebaseService.login(
                email: email,
                password: password
            )

            try await fetchUserInfoWithToken()

        }
        catch {

            if self.currentUser != nil || self.firebaseService.user != nil {
                try? await self.logout()
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

        guard let firebaseUser = self.firebaseService.user else { return }
        let externalId = firebaseUser.uid
        let email = firebaseUser.email ?? ""

        do {

            try await self.firebaseService
                .getAccessTokenForCurrentUser()

            self.apiService
                .accessToken = self.firebaseService.currentAccessToken

            let account = try await self.apiService.getCustomerAccount()
            try Task.checkCancellation()

            guard self.firebaseService.user?.uid == externalId else { return }

            let user = LLUser(
                customerAccount: account,
                externalId: externalId,
                email: email
            )

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

            try await fetchUserInfoWithToken()

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

            self.initialUserLoadTask?.cancel()

            if self.currentUser != nil, self.firebaseService.user != nil {

                do {
                    try await self.apiService.signOutCustomerDevice(installationId: Constants.Device.deviceId)
                }
                catch {

                    self.logError(
                        title: "Device Sign Out Error",
                        message: error.getMessageForError()
                    )

                }

            }

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

        guard self.currentUser != nil else { return }

        do {

            try await self.apiService.deleteCustomerAccount()
            try Task.checkCancellation()

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

        defer {
            self.firebaseService.clearAuthContext()
        }

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

        if isLogin {
            self.firebaseService.beginLoginContext()
        }
        else {
            self.firebaseService.beginSignUpContext()
        }

        do {

            try await self.firebaseService.login(
                token: authResult.idTokenString,
                nonce: authResult.nonce
            )

            self.apiService.accessToken = self.firebaseService.currentAccessToken

            if !isLogin {

                guard let locationId = self.userDefaultsService.lastSelectedLocationId else {
                    throw APIError.serverError(statusCode: 400, errorMessage: "Choose a store before creating an account.")
                }

                let displayName = authResult.name ?? self.firebaseService.user?.displayName ?? "Customer"

                _ = try await self.apiService.registerCustomerAccount(
                    locationId: locationId,
                    displayName: displayName
                )
                try Task.checkCancellation()

            }

            try await fetchUserInfoWithToken()

        }
        catch {

            if self.currentUser != nil || self.firebaseService.user != nil {
                try? await self.logout()
            }

            self.logError(
                title: "Apple Auth Error",
                message: error.getMessageForError()
            )

            throw error

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

                guard let user else {

                    self.initialUserLoadTask?.cancel()
                    self.currentUser = nil
                    self.onInitialLoadCompleted.send(true)
                    return

                }
                guard !self.firebaseService.isSignUpContext,
                      !self.firebaseService.isLoginContext else { return }

                loadInitialUser(user)

            }
            .store(in: &self.cancelBag)

    }

    private func loadInitialUser(_ user: User) {

        self.initialUserLoadTask?.cancel()

        let loadId = UUID()
        self.initialUserLoadId = loadId

        let firebaseService = self.firebaseService
        let apiService = self.apiService
        let analyticsService = self.analyticsService
        let externalId = user.uid
        let email = user.email ?? ""

        self.initialUserLoadTask = Task { @MainActor [weak self] in

            defer {

                if self?.initialUserLoadId == loadId {
                    self?.onInitialLoadCompleted.send(true)
                }

            }

            do {

                try await firebaseService.getAccessTokenForCurrentUser()
                try Task.checkCancellation()

                apiService.accessToken = firebaseService.currentAccessToken

                let account = try await apiService.getCustomerAccount()
                try Task.checkCancellation()

                guard self?.initialUserLoadId == loadId,
                      firebaseService.user?.uid == externalId else { return }

                self?.currentUser = LLUser(
                    customerAccount: account,
                    externalId: externalId,
                    email: email
                )
                analyticsService.identifyUser(account.id)

            }
            catch {

                guard !Task.isCancelled,
                      self?.initialUserLoadId == loadId else { return }

                self?.logError(
                    title: "Load Initial User Error",
                    message: error.getMessageForError()
                )

                if self?.onInitialLoadCompleted.value == true {
                    self?.onError.send(error)
                }

            }

        }

    }

    private func cancelTasks() {

        self.logoutTask?.cancel()
        self.initialUserLoadTask?.cancel()

    }

}

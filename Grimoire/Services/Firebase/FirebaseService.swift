//
//  FirebaseService.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 7/13/24.
//

import SwiftUI
import FirebaseCore
@preconcurrency import FirebaseAuth
import FirebaseStorage
import AuthenticationServices
import Combine

final class FirebaseService: FirebaseServiceProtocol {
    
    internal let loggerName: String = "FIREBASE_SERVICE"
    internal let loggerEmoji: String = "🔥"
    
    enum AppleAuthorizationError: Error, AppCustomError {
        
        case missingCurrentNonce
        case missingIdentityToken
        case missingIdToken
        case authenticationFailed
        
        var message: String {
            switch self {
            case .missingCurrentNonce: return "Invalid state: A login callback was received, but no login request was sent."
            case .missingIdentityToken: return "Invalid state: A login callback was received, but no login request was sent."
            case .missingIdToken: return "Unable to serialize token string from data."
            case .authenticationFailed: return "Apple Authentication has failed."
            }
        }
        
    }
    
    enum FirebaseError: Error, AppCustomError {
        
        case generic(Error)
        case notFound
        case emailAlreadyInUse
        case wrongPassword
        
        var message: String {
            switch self {
            case .generic(let error): return error.getMessageForError()
            case .notFound: return "Account Not found"
            case .emailAlreadyInUse: return "Email already in use"
            case .wrongPassword: return "The email or password you entered is incorrect. Please check your details and try again."
            }
        }
        
    }
    
    @Published private(set) var user: FirebaseAuth.User?
    var userPublisher: AnyPublisher<FirebaseAuth.User?, Never> {
        return self.$user.eraseToAnyPublisher()
    }
    
    @Published private(set) var currentAccessToken: String?
    var currentAccessTokenPublisher: AnyPublisher<String?, Never> {
        return self.$currentAccessToken.eraseToAnyPublisher()
    }
    
    private var idTokenDidChangeListener: NSObjectProtocol?
    private var idTokenUpdateTask: Task<Void, Never>?
    
    var isSignUpContext: Bool = false
    var isLoginContext: Bool = false
        
    init() {
        
        FirebaseApp.configure()
        
        self.user = Auth.auth().currentUser
        self.logInit()
        
        setupFirebaseAuthListener()
        
    }
    
    isolated deinit {
        
        self.idTokenUpdateTask?.cancel()
        
        if let idTokenDidChangeListener {
            Auth.auth().removeIDTokenDidChangeListener(idTokenDidChangeListener)
        }
        
        self.logDeinit()
        
    }
    
    @discardableResult
    func setup() -> Self {
        return self
    }
    
    func signup(email: String,
                password: String) async throws {
        
        do {
            
            let result = try await Auth.auth().createUser(
                withEmail: email,
                password: password
            )
            
            self.isSignUpContext = true
            self.user = result.user
            
            try await self.getAccessTokenForCurrentUser()
            
        } catch let error {
            
            self.logError(
                title: "Sign Up Error",
                message: error.getMessageForError()
            )
            
            if let code = AuthErrorCode(rawValue: error._code) {
                
                switch code {
                case .emailAlreadyInUse: throw FirebaseError.emailAlreadyInUse
                default: throw FirebaseError.generic(error)
                }
                
            }
            
            throw FirebaseError.generic(error)
            
        }
        
    }
    
    func login(email: String,
               password: String) async throws {
        
        do {
            
            let result = try await Auth.auth().signIn(
                withEmail: email,
                password: password
            )
            
            self.isLoginContext = true
            self.user = result.user
            
        } catch let error {
            
            self.logError(
                title: "Login Error",
                message: error.getMessageForError()
            )
            
            if let code = AuthErrorCode(rawValue: error._code) {
                
                switch code {
                case .userNotFound: throw FirebaseError.notFound
                case .wrongPassword: throw FirebaseError.wrongPassword
                case .invalidEmail: throw FirebaseError.notFound
                case .invalidCredential: throw FirebaseError.wrongPassword
                case .accountExistsWithDifferentCredential: throw FirebaseError.wrongPassword
                    
                default: throw FirebaseError.generic(error)
                }
                
            }
            
            throw FirebaseError.generic(error)
            
        }
        
    }
    
    func login(customUserToken: String) async throws {
        
        do {
            
            let result = try await Auth.auth().signIn(withCustomToken: customUserToken)
            self.user = result.user
            
        } catch let error {
            
            self.logError(
                title: "Login Error",
                message: error.getMessageForError()
            )
            
            if let code = AuthErrorCode(rawValue: error._code) {
                
                switch code {
                case .userNotFound: throw FirebaseError.notFound
                case .accountExistsWithDifferentCredential: throw FirebaseError.wrongPassword
                default: throw FirebaseError.generic(error)
                }
                
            }
            
            throw FirebaseError.generic(error)
            
        }
        
    }
    
    func login(token: String,
               nonce: String) async throws {
        
        let credential = OAuthProvider
            .credential(
                providerID: .apple,
                idToken: token,
                rawNonce: nonce
            )
        
        do {
            
            let result = try await Auth.auth().signIn(with: credential)
            self.user = result.user
            
            try await getAccessTokenForCurrentUser()
            
        } catch let error {
            
            self.logError(
                title: "Apple Login Error",
                message: error.getMessageForError()
            )
            
            throw FirebaseError.generic(error)
            
        }
        
    }
    
    func getAccessTokenForCurrentUser() async throws {
        
        guard let user = self.user else { throw FirebaseError.notFound }
        
        do {
            
            let result = try await user.getIDTokenResult(forcingRefresh: true)
            self.currentAccessToken = result.token
            
            await MainActor.run { [weak self, result] in
                self?.log(message: "Firebase User Token \(result.token)")
            }
            
        } catch let error {
            
            self.logError(
                title: "Access Token Error",
                message: error.getMessageForError()
            )
            
            throw FirebaseError.generic(error)
            
        }
        
    }
    
    func resetPassword(email: String) async throws {
        
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        } catch let error {
            
            self.logError(
                title: "Reset Password Error",
                message: error.getMessageForError()
            )
            
            throw FirebaseError.generic(error)
            
        }
        
    }
    
    func updateEmail(newEmail: String) async throws {
        
        guard let user = self.user else { throw FirebaseError.notFound }
        
        do {
            try await user.sendEmailVerification(beforeUpdatingEmail: newEmail)
        } catch let error {
            
            self.logError(
                title: "Update Email Error",
                message: error.getMessageForError()
            )
            
            throw FirebaseError.generic(error)
            
        }
        
    }
    
    func logout() throws {

        do {
            
            try Auth.auth().signOut()
            
            self.user = nil
            self.currentAccessToken = nil
            
        } catch let error {
            
            self.logError(
                title: "Logout Error",
                message: error.getMessageForError()
            )
            
            throw FirebaseError.generic(error)
            
        }

    }
    
    func handleAppleSignupOrLogin(currentNonce: String?,
                                  authorization: ASAuthorization,
                                  completion: @escaping (String?, String?, String, String, Error?) -> ()) {
        
        switch authorization.credential {
            
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            
            guard let nonce = currentNonce else {
                
                self.logError(
                    title: "Apple Sign Up Error",
                    message: "Invalid state: A login callback was received, but no login request was sent."
                )
                
                return completion(nil, nil, "", "", AppleAuthorizationError.missingCurrentNonce)
                
            }
            
            guard let appleIDToken = appleIDCredential.identityToken else {
                
                self.logError(
                    title: "Apple Sign Up Error",
                    message: "Invalid state: A login callback was received, but no login request was sent."
                )
                
                return completion(nil, nil, "", "", AppleAuthorizationError.missingIdentityToken)
                
            }
            
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                
                self.logError(
                    title: "Apple Sign Up Error",
                    message: "Unable to serialize token string from data: \(appleIDToken.debugDescription)"
                )

                return completion(nil, nil, "", "", AppleAuthorizationError.missingIdToken)
                
            }
            
            // The first time they login
            // Name is potentially exposed
            // We must make a call to backend and see if email is registerd
            // If name is available type = "Sign_up" from backend perspective
            
            self.log(message: "\(appleIDCredential.fullName?.familyName ?? "")")
            
            let fullName = "\(appleIDCredential.fullName?.givenName ?? "") \(appleIDCredential.fullName?.familyName ?? "")"
            let email = appleIDCredential.email
            
            completion(fullName, email, idTokenString, nonce, nil)
               
        default:
            
            self.log(message: "\(AppleAuthorizationError.authenticationFailed.message)")
            return completion(nil, nil, "", "", AppleAuthorizationError.authenticationFailed)
            
        }
        
    }
    
    func uploadImage(imageData: Data,
                     bucket: Query.Bucket) async throws -> URL {
        
        
        return try await withCheckedThrowingContinuation { continuation in
            
            let storage = Storage.storage()
            let storageRef = storage.reference()
            let bucketRef = storageRef.child(bucket.rawValue)
            let imageRef = bucketRef.child(UUID().uuidString + ".png" )
            
            imageRef.putData(imageData, metadata: nil) { metadata, error in
                
                if let error = error {
                    
                    continuation.resume(throwing: error)
                    
                } else {
                    
                    imageRef.downloadURL { url, error in
                                                
                        if let error = error {
                            
                            continuation.resume(throwing: error)
                            
                        } else {
                            
                            if let downloadURL = url {
                                continuation.resume(returning: downloadURL)
                            } else {
                                continuation.resume(throwing: FirebaseError.notFound)
                            }
                            
                        }
                        
                    }
                    
                }
                
            }
            
        }

    }
    
    func setupFirebaseAuthListener() {
        
        self.idTokenDidChangeListener = Auth.auth().addIDTokenDidChangeListener { [weak self] auth, user in
            
            guard let self = self else { return }
            self.user = user
            
            self.idTokenUpdateTask?.cancel()
            
            self.idTokenUpdateTask = Task { [weak self] in
                
                guard let self else { return }
                
                guard let user = user else {
                    
                    await MainActor.run { self.currentAccessToken = nil }
                    return
                    
                }
                
                do {
                    
                    let result = try await user.getIDTokenResult(forcingRefresh: false)
                    
                    await MainActor.run {
                        self.currentAccessToken = result.token
                    }
                    
                } catch {
                    
                    guard !Task.isCancelled else { return }
                    
                    self.logError(
                        title: "IDToken Listener Error",
                        message: error.getMessageForError()
                    )
                    
                }
                
            }
            
        }
        
    }
    
}

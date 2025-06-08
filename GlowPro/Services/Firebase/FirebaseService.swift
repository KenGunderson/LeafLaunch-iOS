//
//  FirebaseService.swift
//  GlowPro 
//
//  Created by Sako Hovaguimian on 7/13/24.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseStorage
import AuthenticationServices
import Combine

final class FirebaseService: FirebaseServiceProtocol {
    
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
        
        var message: String {
            switch self {
            case .generic(let error): return error.getMessageForError()
            case .notFound: return "Not found"
            case .emailAlreadyInUse: return "Email already in use"
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
    
    private let logger = GPLogger.service(.firebase)
    
    init() {
        
        FirebaseApp.configure()
        
        self.user = Auth.auth().currentUser
        self.logger.logInit()
        
    }
    
    deinit {
        
        self.logger
            .logDeinit()
        
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
            
            self.user = result.user
            
        } catch let error {
            
            self.logger.error(
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
            
            self.user = result.user
            
        } catch let error {
            
            self.logger.error(
                title: "Login Error",
                message: error.getMessageForError()
            )
            
            if let code = AuthErrorCode(rawValue: error._code) {
                
                switch code {
                case .userNotFound: throw FirebaseError.notFound
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
            
            self.logger.error(
                title: "Login Error",
                message: error.getMessageForError()
            )
            
            if let code = AuthErrorCode(rawValue: error._code) {
                
                switch code {
                case .userNotFound: throw FirebaseError.notFound
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
            
            self.logger.error(
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
            
            self.logger.debugMessage("Firebase User Token \(result.token)")
            
        } catch let error {
            
            self.logger.error(
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
            
            self.logger.error(
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
            
            self.logger.error(
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
            
            self.logger.error(
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
                
                self.logger.error(
                    title: "Apple Sign Up Error",
                    message: "Invalid state: A login callback was received, but no login request was sent."
                )
                
                return completion(nil, nil, "", "", AppleAuthorizationError.missingCurrentNonce)
                
            }
            
            guard let appleIDToken = appleIDCredential.identityToken else {
                
                self.logger.error(
                    title: "Apple Sign Up Error",
                    message: "Invalid state: A login callback was received, but no login request was sent."
                )
                
                return completion(nil, nil, "", "", AppleAuthorizationError.missingIdentityToken)
                
            }
            
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                
                self.logger.error(
                    title: "Apple Sign Up Error",
                    message: "Unable to serialize token string from data: \(appleIDToken.debugDescription)"
                )

                return completion(nil, nil, "", "", AppleAuthorizationError.missingIdToken)
                
            }
            
            // The first time they login
            // Name is potentially exposed
            // We must make a call to backend and see if email is registerd
            // If name is available type = "Sign_up" from backend perspective
            
            self.logger.debugMessage("\(appleIDCredential.fullName?.familyName ?? "")")
            
            let fullName = "\(appleIDCredential.fullName?.givenName ?? "") \(appleIDCredential.fullName?.familyName ?? "")"
            let email = appleIDCredential.email
            
            completion(fullName, email, idTokenString, nonce, nil)
               
        default:
            
            self.logger.debugMessage("\(AppleAuthorizationError.authenticationFailed.message)")
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
    
}

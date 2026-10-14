//
//  FirebaseServiceProtocol.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 7/13/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseStorage
import AuthenticationServices
import Combine

protocol APIAuthTokenProviding: AnyObject {

    var authToken: String? { get }
    func freshAuthToken() async throws -> String?

}

protocol FirebaseServiceProtocol: APIAuthTokenProviding, Sendable, Loggable {

    var user: FirebaseAuth.User? { get }
    var userPublisher: AnyPublisher<FirebaseAuth.User?, Never> { get }

    var currentAccessToken: String? { get }
    var currentAccessTokenPublisher: AnyPublisher<String?, Never> { get }
    var currentAccessTokenExpirationDate: Date? { get }

    var isSignUpContext: Bool { get }
    var isLoginContext: Bool { get }

    func beginSignUpContext()
    func beginLoginContext()
    func clearAuthContext()

    func setup() -> Self

    func signup(email: String, password: String) async throws
    func login(email: String, password: String) async throws
    func login(token: String, nonce: String) async throws

    func handleAppleSignupOrLogin(currentNonce: String?,
                                  authorization: ASAuthorization,
                                  completion: @escaping (String?, String?, String, String, Error?) -> ())

    func logout() throws
    func getAccessTokenForCurrentUser() async throws
    func resetPassword(email: String) async throws
    func updateEmail(newEmail: String) async throws

    func uploadImage(imageData: Data,
                     bucket: Query.Bucket) async throws -> URL

}

extension FirebaseServiceProtocol {

    var authToken: String? {
        return self.currentAccessToken
    }

}

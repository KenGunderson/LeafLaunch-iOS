//
//  AuthServiceProtocol.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 7/13/24.
//

import AuthenticationServices
import Combine

protocol AuthServiceProtocol: AnyObject {
    
    var currentUser: GPUser? { get }
    var currentUserPublisher: AnyPublisher<GPUser?, Never> { get }
    
    var onInitialLoadCompleted: CurrentValueSubject<Bool, Never> { get }
    var onError: CurrentValueSubject<Error?, Never> { get }
            
    func signup(name: String,
                email: String,
                password: String) async throws
    
    func login(email: String,
               password: String) async throws
    
    func handleAppleSignupOrLogin(currentNonce: String?,
                                  authorization: ASAuthorization,
                                  isLogin: Bool) async throws
    
    func fetchUserInfoWithToken() async throws
    func reloadUser() async throws
    func deleteUser() async throws
    
    func updateEmail(_ email: String) async throws
    func resetPassword(email: String) async throws
    
    func logout() async throws
    
}

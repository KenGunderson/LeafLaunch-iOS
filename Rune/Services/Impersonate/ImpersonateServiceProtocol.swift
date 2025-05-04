//
//  ImpersonateServiceProtocol.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 11/5/24.
//

import AuthenticationServices
import Combine

protocol ImpersonateServiceProtocol: AnyObject {
    
    var apiService: APIServiceProtocol { get }
    var firebaseService: FirebaseServiceProtocol { get }
    var authService: AuthServiceProtocol { get }
    
    var originalUser: GPUser? { get }
    var originalUserPublisher: AnyPublisher<GPUser?, Never> { get }
    
    var impersonatedUser: GPUser? { get }
    var impersonatedUserPublisher: AnyPublisher<GPUser?, Never> { get }
    
    var isImpersonating: Bool { get }
            
    func impersonateUser(email: String) async throws
    func revert() async throws
    
}

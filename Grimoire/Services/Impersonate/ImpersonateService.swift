//
//  ImpersonateService.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 11/5/24.
//

import Combine
import Foundation

class ImpersonatingUser: Codable {
    
    let originalUser: GPUser
    let originalUserAccessToken: String
    let impersonatedUser: GPUser
    
    init(originalUser: GPUser,
         originalUserAccessToken: String,
         impersonatedUser: GPUser) {
        
        self.originalUser = originalUser
        self.originalUserAccessToken = originalUserAccessToken
        self.impersonatedUser = impersonatedUser
        
    }
    
}

final class ImpersonateService: ImpersonateServiceProtocol {
    
    internal var apiService: APIServiceProtocol
    internal var authService: AuthServiceProtocol
    internal var userDefaultsService: UserDefaultsServiceProtocol
    internal var firebaseService: FirebaseServiceProtocol
    
    @Published private(set) var originalUser: GPUser?
    var originalUserPublisher: AnyPublisher<GPUser?, Never> {
        return self.$originalUser.eraseToAnyPublisher()
    }
    
    @Published var originalUserAccessToken: String?
    
    @Published private(set) var impersonatedUser: GPUser?
    var impersonatedUserPublisher: AnyPublisher<GPUser?, Never> {
        return self.$impersonatedUser.eraseToAnyPublisher()
    }
    
    var isImpersonating: Bool = false
    
    private let logger = GrimoireLogger.service(.impersonate)
    var cancelBag: CancelBag!
    
    init(firebaseService: FirebaseServiceProtocol,
         apiService: APIServiceProtocol,
         authService: AuthServiceProtocol,
         userDefaultsService: UserDefaultsServiceProtocol) {
        
        self.firebaseService = firebaseService
        self.apiService = apiService
        self.authService = authService
        self.userDefaultsService = userDefaultsService
        
        bindSubscribers()
        
        self.logger.logInit()
        
        let persistedUserData = self.userDefaultsService.impersonatingUserData
        self.setUserDataFromData(persistedUserData)

    }
    
    deinit {
        
        self.logger
            .logDeinit()
        
    }
    
    func impersonateUser(email: String) async throws {
        
        self.originalUser = authService.currentUser
        self.originalUserAccessToken = apiService.accessToken
        
        let token = try await self.apiService.getFirebaseTokenForUser(email: email)
        try await self.firebaseService.login(customUserToken: token)
        
        self.isImpersonating = true
        
    }
    
    func revert() async throws {
        
        guard let originalUser else { return }
        
        let token = try await self.apiService.getFirebaseTokenForUser(email: originalUser.email )
        try await self.firebaseService.login(customUserToken: token)
        self.userDefaultsService.set(impersonatedUser: nil)
        
        self.impersonatedUser = nil
        self.isImpersonating = false
        
    }
    
    // MARK: - Private
    
    private func bindSubscribers() {
        
        self.cancelBag = CancelBag()
        
        self.userDefaultsService
            .impersonatingUserDataPublisher
            .receiveOnMain()
            .sink { [weak self] userData in
                self?.setUserDataFromData(userData)
            }
            .store(in: &self.cancelBag)
        
        self.authService
            .currentUserPublisher
            .receiveOnMain()
            .sink { [weak self] user in
                
                guard let user else { return }
                
                if self?.originalUser == nil {
                    
                    self?.originalUser = user
                    return
                    
                }
                
                if user.email != self?.originalUser?.email {
                    self?.impersonatedUser = user
                }
                
                self?.persistUserData()
                
            }
            .store(in: &self.cancelBag)
        
    }
    
    private func setUserDataFromData(_ data: Data?) {
        
        if let data,
           let decodedData = try? JSONDecoder().decode(ImpersonatingUser.self, from: data) {
            
            self.originalUser = decodedData.originalUser
            self.originalUserAccessToken = decodedData.originalUserAccessToken
            self.impersonatedUser = decodedData.impersonatedUser
            self.isImpersonating = true
            
        } else {
            self.isImpersonating = false
        }
        
    }
    
    private func persistUserData() {
        
        guard let originalUser,
              let originalUserAccessToken,
              let impersonatedUser else { return }
        
        let impersonatingUser = ImpersonatingUser(
            originalUser: originalUser,
            originalUserAccessToken: originalUserAccessToken,
            impersonatedUser: impersonatedUser
        )
        
        self.userDefaultsService
            .set(impersonatedUser: impersonatingUser)
        
    }
    
}

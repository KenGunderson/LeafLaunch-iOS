//
//  ActiveEntityService.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 7/15/25.
//

import Combine

final class ActiveDestinationService: ActiveDestinationServiceProtocol {    
    
    internal let loggerName: String = "ACTIVE_DESTINATION_SERVICE"
    internal let loggerEmoji: String = "🛩️"
    
    private let apiService: APIServiceProtocol!
    private var authService: AuthServiceProtocol?
    private let analyticsService: AnalyticsServiceProtocol!
    
    @Published private(set) var activeDestination: ActiveDestination?
    var activeDestinationPublisher: AnyPublisher<ActiveDestination?, Never> {
        return self.$activeDestination.eraseToAnyPublisher()
    }
    
    @Published private(set) var isOwner: Bool = false
    @Published private(set) var employee: Employee?
    
    var role: Role? {
        return self.employee?.role
    }
    
    var isManager: Bool {
        return self.employee?.role == .manager
    }
    
    var isOwnerOrManager: Bool {
        return self.isOwner || self.role == .manager
    }
    
    init(apiService: APIServiceProtocol,
         analyticsService: AnalyticsServiceProtocol) {
        
        self.apiService = apiService
        self.analyticsService = analyticsService
        self.logInit()
        
    }
    
    deinit {
        self.logDeinit()
    }
    
    func setAuthService(_ authService: AuthServiceProtocol) {
        self.authService = authService
    }
    
    func setActiveDestination(_ destination: ActiveDestination) {
        
        self.activeDestination = destination
        self.log(message: "Set active destination: \(destination)")
        
    }
    
    func removeActiveDestination() {
        
        self.activeDestination = nil
        self.log(message: "Set active destination to NIL")
        
    }
    
    func logout() {
        
        self.activeDestination = nil
        self.log(message: "Set active destination to NIL")
        
    }
    
    private func loadData() {
        
        guard let activeDestination else { return }
        guard let currentUserId = self.authService?.currentUser?.id else { return }
        
        Task { [weak self] in
            
            var business: Business?
            var employee: Employee?
            
            switch activeDestination {
            case .business(let businessId):
                
                business = try await self?.apiService.getBusiness(id: businessId)
                
            case .location(let locationId):
                
                let location = try await self?.apiService.getLocation(id: locationId)
                business = try await self?.apiService.getBusiness(id: location?.businessId ?? "")
                
                let isOwner = business?.owner.id == currentUserId
                
                if !isOwner {
                    
                    let employeeId = try await self?.apiService.getEmployeeByUserIdForLocation(
                        userId: currentUserId,
                        locationId: location?.id ?? ""
                    )
                    
                    employee = try await self?.apiService
                        .getEmployee(id: employeeId ?? "")
                    
                }
                
            }
            
            await MainActor.run { [weak self, business, employee] in
                
                self?.isOwner = (business?.owner.id == currentUserId)
                
                self?.employee = employee
                
                if let business {
                    self?.log(message: "Loaded Business: \(business.id)")
                }
                
                if let employee {
                    self?.log(message: "Loaded Employee: \(employee.id)")
                }
                
            }
            
        }
        
    }
    
}

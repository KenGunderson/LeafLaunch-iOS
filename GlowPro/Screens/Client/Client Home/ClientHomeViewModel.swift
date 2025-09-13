//
//  TabBar1ViewModel.swift
//  GlowPro 
//
//  Created by Sako Hovaguimian on 4/23/25.
//

import Foundation

final class ClientHomeViewModel: ViewModel {
    
    internal let loggerName: String = "CLIENT_DETAILS_VIEW_MODEL"
    internal let loggerEmoji: String = "👤"
    
    private let apiService: APIServiceProtocol
    private let authService: AuthServiceProtocol
    private(set) var alertService: AlertServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let activeDestinationService: ActiveDestinationServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol
    private let viewLifecycleService: ViewLifecycleServiceProtocol
    
    @Published private(set) var client: Client?
    @Published private(set) var location: Location?
    @Published private(set) var activities: [Activity] = []
    @Published private(set) var media: [Media] = []
        
    @Published private(set) var shouldDismiss: Bool = false
    
    private(set) var clientId: String!
    
    private var navigationService: NavigationService?
    private var cancelBag: CancelBag!
    
    var isOwnerOrManager: Bool {
        return self.activeDestinationService.isOwnerOrManager
    }
    
    init(apiService: APIServiceProtocol,
         authService: AuthServiceProtocol,
         alertService: AlertServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         activeDestinationService: ActiveDestinationServiceProtocol,
         userDefaultsService: UserDefaultsServiceProtocol,
         viewLifecycleService: ViewLifecycleServiceProtocol) {
        
        self.apiService = apiService
        self.authService = authService
        self.alertService = alertService
        self.analyticsService = analyticsService
        self.activeDestinationService = activeDestinationService
        self.userDefaultsService = userDefaultsService
        self.viewLifecycleService = viewLifecycleService
        
        self.logInit()
        bindSubsribers()
        
    }
    
    deinit {
        self.logDeinit()
    }
    
    @discardableResult
    func setup(clientId: String) -> Self {
        
        self.clientId = clientId
        return self
        
    }
    
    func setup(navigationService: NavigationService) {
        self.navigationService = navigationService
    }
    
    func bindSubsribers() {
        self.cancelBag = CancelBag()
    }
    
    func loadData() {
        
        self.alertService
            .showAlert(.init(.simpleLoadingIndicator))
        
        Task {
            
            do {
                
                let client = try await self.apiService
                    .getClient(id: self.clientId)
                
                let location = try await self.apiService
                    .getLocation(id: client.locationId ?? "")
                
                let activities = try await self.apiService
                    .getActivitiy(clientId: self.clientId)
                
                let media = try await self.apiService
                    .getMedia(
                        clientId: self.clientId,
                        sortingOption: .newest,
                        tags: []
                    )
                
                await MainActor.run { [weak self] in
                    
                    self?.client = client
                    self?.location = location
                    self?.activities = activities
                    self?.media = media
                    
                }
                
            }
            catch {
                
                self.alertService.showAlert(.init(
                    .appAlert(
                        .error(
                            message: Constants.Message.errorMessage("client"),
                            action: {
                                
                                self.shouldDismiss = true
                                
                            })
                    ))
                )
                
            }
            
            self.alertService
                .dismissLoadingIndicator()
            
        }
        
    }
    
    func buildSubtitleString(client: Client) -> String {
        
        var formattedString = ""
        
        if let email = client.email {
            formattedString += "\(email)"
        }
        
        if let phoneNumber = client.phoneNumber {
            formattedString += (formattedString.isEmpty ? "\(phoneNumber)" : " • \(phoneNumber)")
        }
        
        if let dateOfBirth = client.dateOfBirth {
            
            let dateString = dateOfBirth.formatted(date: .abbreviated, time: .omitted)
            formattedString += (formattedString.isEmpty ? "\(dateString)" : " • \(dateString)")
            
        }
        
        return formattedString.isEmpty ? "Update Client Information" : formattedString
        
    }
    
}

extension ClientHomeViewModel {
    
    func track() {
        self.analyticsService.track(screen: .client(.clientHome(clientId: self.clientId)))
    }
    
}

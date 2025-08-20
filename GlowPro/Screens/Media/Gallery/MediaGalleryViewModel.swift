//
//  MediaGalleryViewModel.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/20/25.
//

import Foundation

final class MediaGalleryViewModel: ViewModel {
    
    internal let loggerName: String = "MEDIA_GALLERY_VIEW_MODEL"
    internal let loggerEmoji: String = "📸"
    
    private let apiService: APIServiceProtocol
    private let authService: AuthServiceProtocol
    private(set) var alertService: AlertServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol
    
    @Published private(set) var media: [Media] = []

    private var navigationService: NavigationService?
    private var cancelBag: CancelBag!
    
    init(apiService: APIServiceProtocol,
         authService: AuthServiceProtocol,
         alertService: AlertServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         userDefaultsService: UserDefaultsServiceProtocol) {
        
        self.apiService = apiService
        self.authService = authService
        self.alertService = alertService
        self.analyticsService = analyticsService
        self.userDefaultsService = userDefaultsService
        
        self.logInit()
        
    }
    
    deinit {
        self.logDeinit()
    }
    
//    @discardableResult
//    func setup(businessId: String?) -> Self {
//        
//        self.businessId = businessId
//        return self
//        
//    }
    
    func setup(navigationService: NavigationService) {
        self.navigationService = navigationService
    }
    
    func loadData() {
//        
//        guard let businessId else { return }
//        
//        self.alertService
//            .showAlert(.init(.simpleLoadingIndicator))
//        
//        Task {
//            
//            do {
//                
//                let business = try await self.apiService
//                    .getBusiness(id: businessId)
//                
//                await MainActor.run { [weak self] in
//                    
//                    self?.business = business
//                    self?.name = business.name
//                    self?.email = business.email ?? ""
//                    self?.phone = business.phoneNumber ?? ""
//                    self?.street = business.address?.street ?? ""
//                    self?.street2 = business.address?.street2 ?? ""
//                    self?.city = business.address?.city ?? ""
//                    self?.state = business.address?.state ?? ""
//                    self?.zip = business.address?.zip ?? ""
//                    
//                }
//                
//            }
//            catch {
//                
//                self.alertService.showAlert(.init(
//                    .appAlert(
//                        .error(
//                            message: Constants.Error.fetchErrorMessage("business details"),
//                            action: {})
//                    ))
//                )
//                
//            }
//            
//            self.alertService
//                .dismissLoadingIndicator()
//            
//        }
//        
    }
    
    private func bindSubscribers() {
        self.cancelBag = CancelBag()
    }
    
}

extension MediaGalleryViewModel {
    
    func track() {
        self.analyticsService.track(screen: .media(.gallery))
    }
    
}

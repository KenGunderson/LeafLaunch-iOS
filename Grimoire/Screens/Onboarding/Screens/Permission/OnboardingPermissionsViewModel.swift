//
//  OnboardingPermissionsViewModel.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 7/3/25.
//

import Combine

final class OnboardingPermissionsViewModel: ViewModel {
    
    internal let loggerName: String = "ONBOARDING_PERMISSION_VIEW_MODEL"
    internal let loggerEmoji: String = "🛹"
    
    @Published private(set) var count: Int = 0
    
    private let analyticsService: AnalyticsServiceProtocol
    var permissionService: PermissionsServiceProtocol
    private let alertService: AlertServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol
    
    var cameraPermission: CameraPermissionServiceProtocol {
        return self.permissionService.cameraPermissionService
    }
    
    var mediaPermission: MediaPermissionServiceProtocol {
        return self.permissionService.mediaPermissionService
    }
    
    var pushNotificationPermission: PushNotificationPermissionServiceProtocol {
        return self.permissionService.pushNotificationPermissionService
    }
    
    var trackingPermission: AppTrackingPermissionServiceProtocol {
        return self.permissionService.appTrackingPermissionService
    }
    
    private var cancelBag: CancelBag!
    
    init(analyticsService: AnalyticsServiceProtocol,
         permissionService: PermissionsServiceProtocol,
         alertService: AlertServiceProtocol,
         userDefaultsService: UserDefaultsServiceProtocol) {
        
        self.analyticsService = analyticsService
        self.userDefaultsService = userDefaultsService
        self.alertService = alertService
        self.permissionService = permissionService
        
        self.logInit()
        bindSubscribers()
        
    }
    
    deinit {
        self.logDeinit()
    }
    
    private func bindSubscribers() {
        
        self.cancelBag = CancelBag()
        
        permissionService
          .cameraPermissionService
          .permissionGrantedPublisher
          .receiveOnMain()
          .sink { [weak self] _ in
              self?.count += 1
          }
          .store(in: &cancelBag)
        
        permissionService
          .mediaPermissionService
          .permissionGrantedPublisher
          .receiveOnMain()
          .sink { [weak self] _ in
              self?.count += 1
          }
          .store(in: &cancelBag)
        
        permissionService
          .pushNotificationPermissionService
          .permissionGrantedPublisher
          .receiveOnMain()
          .sink { [weak self] _ in
              self?.count += 1
          }
          .store(in: &cancelBag)
        
        permissionService
          .appTrackingPermissionService
          .permissionGrantedPublisher
          .receiveOnMain()
          .sink { [weak self] _ in
              self?.count += 1
          }
          .store(in: &cancelBag)
        
    }
    
}

extension OnboardingPermissionsViewModel {
    
    func track() {
        self.analyticsService.track(screen: .onboarding(.permission))
    }
    
}

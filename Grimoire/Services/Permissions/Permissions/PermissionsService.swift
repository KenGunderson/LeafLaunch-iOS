//
//  PermissionsService.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 7/14/24.
//

import Combine

enum PermissionError: Error, AppCustomError {
    
    case alreadyRequested
    
    var message: String {
        switch self {
        case .alreadyRequested: return "This permission has already been requested. Please go to Apple's settings and enable it."
        }
    }
    
}

enum Permission: String, CaseIterable {
    
    case camera
    case media
    case pushNotification
    case appTracking
    
    var displayName: String {
        switch self {
        case .camera: return "Camera"
        case .media: return "Media"
        case .pushNotification: return "Push Notification"
        case .appTracking: return "Analytics"
        }
    }
    
}

final class PermissionsService: PermissionsServiceProtocol {
    
    internal let loggerName: String = "PERMISSIONS_SERVICE"
    internal let loggerEmoji: String = "🤚🏻"
    
    internal let cameraPermissionService: CameraPermissionServiceProtocol
    internal let mediaPermissionService: MediaPermissionServiceProtocol
    internal let pushNotificationPermissionService: PushNotificationPermissionServiceProtocol
    internal let appTrackingPermissionService: AppTrackingPermissionServiceProtocol
       
    @Published private(set) var shouldShowPermissionView: Bool = false
    var shouldShowPermissionViewPublisher: AnyPublisher<Bool, Never> {
        return self.$shouldShowPermissionView.eraseToAnyPublisher()
    }
    
    private var cancelBag: CancelBag!
    
    init(cameraPermissionService: CameraPermissionServiceProtocol,
         mediaPermissionService: MediaPermissionServiceProtocol,
         pushNotificationPermissionService: PushNotificationPermissionServiceProtocol,
         appTrackingPermissionService: AppTrackingPermissionServiceProtocol) {
        
        self.cameraPermissionService = cameraPermissionService
        self.mediaPermissionService = mediaPermissionService
        self.pushNotificationPermissionService = pushNotificationPermissionService
        self.appTrackingPermissionService = appTrackingPermissionService
        
        self.logInit()
        
        bindSubscribers()
        validatePermissions()
        
    }
    
    deinit {
        self.logDeinit()
    }
    
    private func bindSubscribers() {
        
        self.cancelBag = CancelBag()
        
        self.cameraPermissionService
            .shouldPromptForPermissionsPublisher
            .receiveOnMain()
            .sink { [weak self] _ in
                self?.validatePermissions()
            }
            .store(in: &self.cancelBag)
        
        self.mediaPermissionService
            .shouldPromptForPermissionsPublisher
            .receiveOnMain()
            .sink { [weak self] _ in
                self?.validatePermissions()
            }
            .store(in: &self.cancelBag)
        
        self.pushNotificationPermissionService
            .shouldPromptForPermissionsPublisher
            .receiveOnMain()
            .sink { [weak self] _ in
                self?.validatePermissions()
            }
            .store(in: &self.cancelBag)
        
        self.appTrackingPermissionService
            .shouldPromptForPermissionsPublisher
            .receiveOnMain()
            .sink { [weak self] _ in
                self?.validatePermissions()
            }
            .store(in: &self.cancelBag)
        
    }
    
    func validatePermissions() {
                
        if (!self.cameraPermissionService.shouldPromptForPermissions &&
            !self.mediaPermissionService.shouldPromptForPermissions &&
            !self.pushNotificationPermissionService.shouldPromptForPermissions &&
            !self.appTrackingPermissionService.shouldPromptForPermissions) {
            
            if self.shouldShowPermissionView {
                
                self.shouldShowPermissionView = false
                return
                
            }
            
        }
        
        self.shouldShowPermissionView = true
        
    }
    
    func requestPermission(_ permission: Permission) {
        
        switch permission {
        case .camera: self.cameraPermissionService.requestPermission()
        case .media: self.mediaPermissionService.requestPermission()
        case .pushNotification: self.pushNotificationPermissionService.requestPermission()
        case .appTracking: self.appTrackingPermissionService.requestPermission()
        }
        
    }
    
    private func requestPermissionsIfNeeded() {
        
        if cameraPermissionService.shouldPromptForPermissions {
            self.cameraPermissionService.requestPermissionIfNeeded()
        }
        else if mediaPermissionService.shouldPromptForPermissions {
            self.mediaPermissionService.requestPermissionIfNeeded()
        }
        else if pushNotificationPermissionService.shouldPromptForPermissions {
            self.pushNotificationPermissionService.requestPermissionIfNeeded()
        }
        else if appTrackingPermissionService.shouldPromptForPermissions {
            self.appTrackingPermissionService.requestPermissionIfNeeded()
        }
        
    }
    
}

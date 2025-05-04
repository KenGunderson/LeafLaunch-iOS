//
//  AppTrackingPermissionService.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 7/14/24.
//

import Combine
import UIKit
import AppTrackingTransparency

class AppTrackingPermissionService: AppTrackingPermissionServiceProtocol {
    
    @Published private(set) var permissionGranted: Bool? = false
    var permissionGrantedPublisher: AnyPublisher<Bool?, Never> {
        return self.$permissionGranted.eraseToAnyPublisher()
    }
    
    @Published private(set) var shouldPromptForPermissions: Bool = false
    var shouldPromptForPermissionsPublisher: AnyPublisher<Bool, Never> {
        return self.$shouldPromptForPermissions.eraseToAnyPublisher()
    }
    
    @Published private(set) var attStatus: ATTStatus?
    var attStatusPublisher: AnyPublisher<ATTStatus?, Never> {
        return self.$attStatus.eraseToAnyPublisher()
    }
    
    init() {
        checkAuthorizationStatus()
    }
    
    func requestPermissionIfNeeded() {
        if self.shouldPromptForPermissions {
            requestPermission()
        }
    }
    
    func requestPermission() {
        
        ATTrackingManager.requestTrackingAuthorization { status in
            
            DispatchQueue.main.async {
                
                self.attStatus = .fromAuthorizationStatus(status)
                
                switch status {
                case .authorized:
                    
                    self.permissionGranted = true
                    self.shouldPromptForPermissions = false
                    
                case .notDetermined:
                    
                    self.permissionGranted = nil
                    self.shouldPromptForPermissions = true
                    
                default:
                    self.permissionGranted = false
                    self.shouldPromptForPermissions = false
                }
                
            }
            
        }
        
    }
    
    private func checkAuthorizationStatus() {
        
        let status = ATTrackingManager.trackingAuthorizationStatus
        
        DispatchQueue.main.async {
            self.attStatus = .fromAuthorizationStatus(status)
        }
        
        switch status {
        case .authorized:
            
            self.permissionGranted = true
            self.shouldPromptForPermissions = false
            
        case .notDetermined:
            
            self.permissionGranted = nil
            self.shouldPromptForPermissions = true
            
        default:
            
            self.permissionGranted = false
            self.shouldPromptForPermissions = false
        }
        
    }
    
}

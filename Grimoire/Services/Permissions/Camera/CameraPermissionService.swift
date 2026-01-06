//
//  CameraPermissionService.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 7/14/24.
//

import Combine
import AVFoundation
import UIKit

final class CameraPermissionService: CameraPermissionServiceProtocol {
    
    internal let loggerName: String = "CAMERA_PERMISSION_SERVICE"
    internal let loggerEmoji: String = "🤚🏻"
    
    @Published private(set) var permissionGranted: Bool = false
    var permissionGrantedPublisher: AnyPublisher<Bool, Never> {
        return self.$permissionGranted.eraseToAnyPublisher()
    }
    
    @Published private(set) var shouldPromptForPermissions: Bool = false
    var shouldPromptForPermissionsPublisher: AnyPublisher<Bool, Never> {
        return self.$shouldPromptForPermissions.eraseToAnyPublisher()
    }
    
    init() {
        
        self.logInit()
        checkAuthorizationStatus()
        
    }
    
    deinit {
        self.logDeinit()
    }
    
    func requestPermissionIfNeeded() {
        
        if self.shouldPromptForPermissions {
            requestPermission()
        }
        
    }
    
    func requestPermission() {
        
        AVCaptureDevice
            .requestAccess(for: .video) { accessGranted in
                
                DispatchQueue.main.async {
                    
                    self.permissionGranted = accessGranted
                    self.shouldPromptForPermissions = false
                    
                }
                
            }
        
    }
    
    private func checkAuthorizationStatus() {
        
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .notDetermined:
            
            self.shouldPromptForPermissions = true
            
        case .denied:
            
            self.permissionGranted = false
            self.shouldPromptForPermissions = false
            
        case .authorized:
            
            self.permissionGranted = true
            self.shouldPromptForPermissions = false
            
        default:
            self.shouldPromptForPermissions = false
        }
        
    }
    
}

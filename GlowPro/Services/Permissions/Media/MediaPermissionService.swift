//
//  MediaPermissionService.swift
//  GlowPro 
//
//  Created by Sako Hovaguimian on 7/14/24.
//

import Combine
import PhotosUI
import UIKit

class MediaPermissionService: MediaPermissionServiceProtocol {
    
    @Published private(set) var permissionGranted: Bool = false
    var permissionGrantedPublisher: AnyPublisher<Bool, Never> {
        return self.$permissionGranted.eraseToAnyPublisher()
    }
    
    @Published private(set) var shouldPromptForPermissions: Bool = false
    var shouldPromptForPermissionsPublisher: AnyPublisher<Bool, Never> {
        return self.$shouldPromptForPermissions.eraseToAnyPublisher()
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
        
        PHPhotoLibrary
            .requestAuthorization(for: .readWrite) { status in
            
            DispatchQueue.main.async {
                
                self.permissionGranted = (status == .authorized)
                self.shouldPromptForPermissions = false
                
            }
            
        }
        
    }
    
    private func checkAuthorizationStatus() {
        
        let status = PHPhotoLibrary.authorizationStatus()
        
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

//
//  PushNotificationPermissionService.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 7/14/24.
//

import Combine
import UserNotifications
import UIKit

class PushNotificationPermissionService: PushNotificationPermissionServiceProtocol {
    
    @Published private(set) var permissionGranted: Bool = false
    var permissionGrantedPublisher: AnyPublisher<Bool, Never> {
        return self.$permissionGranted.eraseToAnyPublisher()
    }
    
    @Published private(set) var shouldPromptForPermissions: Bool = false
    var shouldPromptForPermissionsPublisher: AnyPublisher<Bool, Never> {
        return self.$shouldPromptForPermissions.eraseToAnyPublisher()
    }
    
    init() {
        
        Task {
            await checkAuthorizationStatus()
        }
        
    }
    
    func requestPermissionIfNeeded() {
        
        if self.shouldPromptForPermissions {
            requestPermission()
        }
        
    }
    
    func requestPermission() {
        
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        
        UNUserNotificationCenter
            .current()
            .requestAuthorization(options: options) { accessGranted, _ in
            
            DispatchQueue.main.async {
                
                self.permissionGranted = accessGranted
                self.shouldPromptForPermissions = false
                UIApplication.shared.registerForRemoteNotifications()
                
            }
            
        }
        
    }
    
    private func checkAuthorizationStatus() async -> Bool {
        
        return await withCheckedContinuation { continuation in
            
            UNUserNotificationCenter
                .current()
                .getNotificationSettings { status in
                
                switch status.authorizationStatus {
                case .notDetermined:
                    
                    DispatchQueue.main.async {
                        
                        self.shouldPromptForPermissions = true
                        continuation.resume(returning: true)
                        
                    }
                    
                case .authorized:
                    
                    DispatchQueue.main.async {
                        
                        self.permissionGranted = true
                        self.shouldPromptForPermissions = false
                        continuation.resume(returning: false)
                        
                    }
                    
                default:
                    
                    DispatchQueue.main.async {
                        
                        self.shouldPromptForPermissions = false
                        continuation.resume(returning: false)
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
}

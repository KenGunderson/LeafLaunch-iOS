//
//  SpeechRecognitionPermissionService.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 4/4/26.
//

import Combine
import Speech

final class SpeechRecognitionPermissionService: SpeechRecognitionPermissionServiceProtocol {
    
    internal let loggerName: String = "SPEECH_RECOGNITION_PERMISSION_SERVICE"
    internal let loggerEmoji: String = "🗣️"
    
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
        
        Task { [weak self] in
            
            let status = await Self.requestAuthorizationStatus()
            
            await MainActor.run { [weak self] in
                self?.applyAuthorizationStatus(status)
            }
            
        }
        
    }
    
    private func checkAuthorizationStatus() {
        
        let status = SFSpeechRecognizer.authorizationStatus()
        
        self.applyAuthorizationStatus(status)
        
    }
    
    private nonisolated static func requestAuthorizationStatus() async -> SFSpeechRecognizerAuthorizationStatus {
        
        return await withCheckedContinuation { continuation in
            
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
            
        }
        
    }
    
    @MainActor
    private func applyAuthorizationStatus(_ status: SFSpeechRecognizerAuthorizationStatus) {
        
        switch status {
        case .notDetermined:
            
            self.permissionGranted = false
            self.shouldPromptForPermissions = true
            
        case .denied,
                .restricted:
            
            self.permissionGranted = false
            self.shouldPromptForPermissions = false
            
        case .authorized:
            
            self.permissionGranted = true
            self.shouldPromptForPermissions = false
            
        @unknown default:
            
            self.permissionGranted = false
            self.shouldPromptForPermissions = false
            
        }
        
    }
    
}

//
//  MicrophonePermissionService.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 4/4/26.
//

import Combine
import AVFoundation

final class MicrophonePermissionService: MicrophonePermissionServiceProtocol {
    
    internal let loggerName: String = "MICROPHONE_PERMISSION_SERVICE"
    internal let loggerEmoji: String = "🎙️"
    
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
            
            let accessGranted = await Self.requestRecordPermission()
            
            await MainActor.run { [weak self] in
                self?.applyPermissionResponse(accessGranted)
            }
            
        }
        
    }
    
    private func checkAuthorizationStatus() {
        
        let status = AVAudioApplication.shared.recordPermission
        
        self.applyAuthorizationStatus(status)
        
    }
    
    private nonisolated static func requestRecordPermission() async -> Bool {
        
        return await withCheckedContinuation { continuation in
            
            AVAudioApplication.requestRecordPermission { accessGranted in
                continuation.resume(returning: accessGranted)
            }
            
        }
        
    }
    
    @MainActor
    private func applyPermissionResponse(_ accessGranted: Bool) {
        
        self.permissionGranted = accessGranted
        self.shouldPromptForPermissions = false
        
    }
    
    @MainActor
    private func applyAuthorizationStatus(_ status: AVAudioApplication.recordPermission) {
        
        switch status {
        case AVAudioApplication.recordPermission.undetermined:
            
            self.shouldPromptForPermissions = true
            
        case AVAudioApplication.recordPermission.denied:
            
            self.permissionGranted = false
            self.shouldPromptForPermissions = false
            
        case AVAudioApplication.recordPermission.granted:
            
            self.permissionGranted = true
            self.shouldPromptForPermissions = false
            
        @unknown default:
            
            self.permissionGranted = false
            self.shouldPromptForPermissions = false
            
        }
        
    }
    
}

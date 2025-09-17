//
//  CameraViewModel.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/30/25.
//

import AVFoundation
import SwiftUI

public final class CameraViewModel: ObservableObject {
    
    private let cameraService: CameraServiceProtocol
    
    @Published public var captureMode: CameraCaptureMode = .single(nil)
    @Published public var errorMessage: String?
    @Published public var isShutterDisabled: Bool = false
    
    private var context: MediaContext!
    
    public init(cameraService: CameraServiceProtocol) {
        self.cameraService = cameraService
    }
    
    public var session: AVCaptureSession {
        self.cameraService.session
    }
    
    @discardableResult
    func setup(context: MediaContext,
               mode: CameraCaptureMode = .single(nil)) -> Self {
        
        self.context = context
        self.captureMode = mode
        
        return self
        
    }
    
    public func setup() {
        
        guard !ProcessInfo.isPreview,
              !ProcessInfo.isSimulator else { return }
        
        Task { @MainActor [weak self] in
            
            let errorMessage: String?
            let status = await AVCaptureDevice.requestAccess(for: .video)
            
            if !status {
                
                await MainActor.run { [weak self] in
                    self?.errorMessage = CameraError.permissionDenied.message
                }
                
                return
                
            }
            
            do {
                
                try self?.cameraService.configure()
                self?.cameraService.start()
                
            } catch {
                
                await MainActor.run { [weak self] in
                    self?.errorMessage = error.localizedDescription
                }
                
            }
            
        }
        
    }
    
    public func teardown() {
        
        self.cameraService
            .teardown()
        
    }
    
    public func shutter() {
        
        self.isShutterDisabled = true
        
        self.cameraService.capturePhoto { [weak self] result in
            
            DispatchQueue.main.async { [weak self] in
                                
                switch result {
                case .success(let image): self?.captureMode.addPhoto(image)
                case .failure(let error): self?.errorMessage = error.localizedDescription
                }
                
                self?.isShutterDisabled = false
                
            }
            
        }
        
    }
    
}

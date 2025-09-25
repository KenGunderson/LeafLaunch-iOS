//
//  CameraViewModel.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/30/25.
//

import AVFoundation
import SwiftUI

final class CameraViewModel: ViewModel {
    
    internal let loggerName: String = "CAMERA_VIEW_MODEL"
    internal let loggerEmoji: String = "📸"
    
    private let cameraService: CameraServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    
    @Published private(set) var captureMode: CameraCaptureMode = .single(nil)
    @Published private(set) var errorMessage: String?
    @Published private(set) var isShutterDisabled: Bool = false
    
    @Published private(set) var cameraFlashMode: CameraFlashMode = .off
    @Published var zoomFactor: CGFloat = 1.0
    
    private(set) var context: MediaContext!
    private var cancelBag: CancelBag!
    
    var allImages: [UIImage] {
        return self.captureMode.allPhotos
    }
    
    public init(cameraService: CameraServiceProtocol,
                analyticsService: AnalyticsServiceProtocol) {
        
        self.cameraService = cameraService
        self.analyticsService = analyticsService
        
        self.logInit()
        bindSubscribers()
        
    }
    
    public var session: AVCaptureSession {
        self.cameraService.session
    }
    
    deinit {
        self.logDeinit()
    }
    
    @discardableResult
    func setup(context: MediaContext,
               mode: CameraCaptureMode = .single(nil)) -> Self {
        
        self.context = context
        self.captureMode = mode
        
        return self
        
    }
    
    func setup() {
        
        guard !ProcessInfo.isPreview,
              !ProcessInfo.isSimulator else { return }
        
        Task { @MainActor [weak self] in
            
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
    
    func teardown() {
        
        self.cameraService
            .teardown()
        
    }
    
    func shutter() {
        
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
    
    func toggleFlash() {
        
        self.cameraService
            .toggleFlash()
        
    }
    
    func setCameraFlashMode(_ mode: CameraFlashMode) {
        
        let shouldTurnAutoOn = self.cameraFlashMode != .auto
        
        self.cameraService
            .setFlashMode(shouldTurnAutoOn ? .auto : .off)
        
    }
    
    func zoom(scale: CGFloat) {
        
        self.cameraService
            .zoom(by: scale, animated: true)
        
    }
    
    private func bindSubscribers() {
        
        self.cancelBag = CancelBag()
     
        self.cameraService
            .flashModePublisher
            .receiveOnMain()
            .sink { [weak self] in
                self?.cameraFlashMode = $0
            }
            .store(in: &self.cancelBag)
        
        self.cameraService
            .zoomFactorPublisher
            .receiveOnMain()
            .sink { [weak self] in
                self?.zoomFactor = $0
            }
            .store(in: &self.cancelBag)
        
    }

}

extension CameraViewModel {
    
    func track() {
        
        self.analyticsService
            .track(screen: .media(.camera))
        
    }
    
}

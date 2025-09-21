//
//  CameraService.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/30/25.
//

@preconcurrency import Photos
import UIKit
import Combine

final class CameraService: NSObject, CameraServiceProtocol {
    
    internal let loggerName: String = "CAMERA_SERVICE"
    internal let loggerEmoji: String = "📷"
    
    public let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    
    private let photoOutput = AVCapturePhotoOutput()
    private var videoDeviceInput: AVCaptureDeviceInput?
    private var captureCompletion: ((Result<UIImage, Error>) -> Void)?
    
    private var isConfigured: Bool = false
    
    @Published internal var flashMode: CameraFlashMode = .off
    var flashModePublisher: AnyPublisher<CameraFlashMode, Never> {
        return self.$flashMode.eraseToAnyPublisher()
    }
    
    @Published internal var zoomFactor: CGFloat = 1.0
    var zoomFactorPublisher: AnyPublisher<CGFloat, Never> {
        return self.$zoomFactor.eraseToAnyPublisher()
    }
    
    var maxZoomFactor: CGFloat {
        
        guard let device = self.videoDeviceInput?.device else { return 1.0 }
        return min(8.0, device.activeFormat.videoMaxZoomFactor)
        
    }
    
    override init() {
        
        super.init()
        self.logInit()
        
    }
    
    deinit {
        self.logDeinit()
    }
    
    public func configure() throws {
        
        // Always perform configuration on the sessionQueue to avoid races
        var thrownError: Error?
        
        self.sessionQueue.sync { [weak self] in
            
            guard let strongSelf = self else { return }
            
            // If already configured, do nothing (safe early return)
            if strongSelf.isConfigured {
                
                strongSelf.log(message: "Session already configured; skipping reconfiguration.")
                return
                
            }
            
            strongSelf.session.beginConfiguration()
            strongSelf.session.sessionPreset = .photo
            
            // If something was left over (defensive), remove it first
            for input in strongSelf.session.inputs {
                strongSelf.session.removeInput(input)
            }
            
            for output in strongSelf.session.outputs {
                strongSelf.session.removeOutput(output)
            }
            
            guard let device = AVCaptureDevice.default(
                .builtInWideAngleCamera,
                for: .video,
                position: .back
            ) else {
                
                strongSelf.logError(message: "Error: No wide angle camera found")
                strongSelf.session.commitConfiguration()
                thrownError = CameraError.deviceUnavailable
                return
                
            }
            
            do {
                
                let input = try AVCaptureDeviceInput(device: device)
                
                if strongSelf.session.canAddInput(input) {
                    
                    strongSelf.session.addInput(input)
                    strongSelf.videoDeviceInput = input
                    strongSelf.log(message: "Added video device input")
                    
                } else {
                    
                    strongSelf.logError(message: "Error: Failed to add video device input")
                    strongSelf.session.commitConfiguration()
                    thrownError = CameraError.inputAddFailed
                    return
                    
                }
                
            } catch {
                
                strongSelf.logError(message: "Error creating device input: \(error.localizedDescription)")
                strongSelf.session.commitConfiguration()
                thrownError = error
                
                return
                
            }
            
            if !strongSelf.session.outputs.contains(strongSelf.photoOutput) {
                
                if strongSelf.session.canAddOutput(strongSelf.photoOutput) {
                    
                    strongSelf.session.addOutput(strongSelf.photoOutput)
                    strongSelf.log(message: "Added photo output")
                    
                } else {
                    
                    strongSelf.logError(message: "Error: Failed to add photo output")
                    strongSelf.session.commitConfiguration()
                    thrownError = CameraError.outputAddFailed
                    return
                    
                }
                
            }
            
            strongSelf.session.commitConfiguration()
            strongSelf.isConfigured = true
            strongSelf.log(message: "Session configuration committed")
            
        }
        
        if let thrownError {
            throw thrownError
        }
        
    }
    

    public func start() {
        
        self.sessionQueue.async { [weak self] in
            
            guard let strongSelf = self else { return }
            
            strongSelf.log(message: "Attempting to start camera session...")
            
            if !strongSelf.session.isRunning {
                
                strongSelf.session.startRunning()
                strongSelf.log(message: "Camera session started")
                
            } else {
                strongSelf.log(message: "Camera session already running")
            }
            
        }
        
    }
    
    public func stop() {
        
        self.log(message: "Attempting to stop camera session...")
        
        self.sessionQueue.async { [weak self] in
            
            guard let strongSelf = self else { return }
            
            if strongSelf.session.isRunning {
                
                strongSelf.session.stopRunning()
                strongSelf.log(message: "Camera session stopped")
                
            }
            
        }
        
    }
    
    public func teardown() {
        
        self.log(message: "Tearing down camera session...")
        
        self.sessionQueue.async { [weak self] in
            
            guard let strongSelf = self else { return }
            
            if strongSelf.session.isRunning {
                strongSelf.session.stopRunning()
            }
            
            strongSelf.session.beginConfiguration()
            
            for input in strongSelf.session.inputs {
                strongSelf.session.removeInput(input)
            }
            
            for output in strongSelf.session.outputs {
                strongSelf.session.removeOutput(output)
            }
            
            strongSelf.session.commitConfiguration()
            strongSelf.videoDeviceInput = nil
            strongSelf.isConfigured = false
            
            strongSelf.log(message: "Camera session torn down and ready for reconfiguration")
            
        }
        
    }
    
    // **************************************
    // MARK: - Capture
    // **************************************
    
    public func capturePhoto(_ completion: @escaping (Result<UIImage, Error>) -> Void) {
        
        self.sessionQueue.async { [weak self] in
            
            guard let strongSelf = self else { return }
            
            let settings = AVCapturePhotoSettings()
        
            if let device = self?.videoDeviceInput?.device,
               device.hasFlash {
                
                settings.flashMode = self?.flashMode.captureDeviceMode ?? .off
                
            }
            
            strongSelf.captureCompletion = completion
            
            strongSelf.photoOutput.capturePhoto(
                with: settings,
                delegate: strongSelf
            )
            
            strongSelf.log(message: "Capturing photo...")
            
        }
        
    }
    
    // **************************************
    // MARK: - CAMERA FLASH MODE
    // **************************************
    
    func setFlashMode(_ mode: CameraFlashMode) {
        
        self.sessionQueue.async { [weak self, mode] in
            
            self?.flashMode = mode
            self?.log(message: "Flash is now \(mode.displayName)")
            
        }
        
    }

    func toggleFlash() {
        
        self.sessionQueue.async { [weak self] in
            
            guard let self = self else { return }
            
            let shouldTurnOn = (self.flashMode == .auto) || (self.flashMode == .off)
            self.flashMode = shouldTurnOn ? .on : .off
            
            self.log(message: "Flash toggled to \(self.flashMode.displayName)")
            
        }
        
    }
    
    // **************************************
    // MARK: - ZOOM MODE
    // **************************************
    
    func setZoom(factor: CGFloat,
                 animated: Bool = true,
                 rampRate: Float = 8.0) {
        
        self.sessionQueue.async { [weak self] in
            
            guard let self = self,
                  let device = self.videoDeviceInput?.device else { return }
            
            let clamped = max(0.5, min(factor, self.maxZoomFactor))

            do {
                
                try device.lockForConfiguration()
                
                if animated,
                   device.responds(to: #selector(getter: AVCaptureDevice.isRampingVideoZoom)) {
                    
                    device.ramp(toVideoZoomFactor: clamped, withRate: max(1.0, rampRate))
                    
                } else {
                    device.videoZoomFactor = clamped
                }
                
                device.unlockForConfiguration()
                self.log(message: "Zoom set to \(clamped)")
                
            } catch {
                self.logError(message: "Failed to set zoom: \(error.localizedDescription)")
            }
            
        }
        
    }
    
    func zoom(by multiplier: CGFloat,
              animated: Bool = false) {
        
        self.sessionQueue.async { [weak self] in
            
            guard let self = self,
                  let device = self.videoDeviceInput?.device else { return }
            
            let target = device.videoZoomFactor * multiplier
            
            self.setZoom(
                factor: target,
                animated: animated
            )
            
        }
        
    }
    
}

// **************************************
// MARK: - AVCapturePhotoCaptureDelegate
// **************************************

extension CameraService: AVCapturePhotoCaptureDelegate {
    
    public func photoOutput(_ output: AVCapturePhotoOutput,
                            didFinishProcessingPhoto photo: AVCapturePhoto,
                            error: Error?) {
        
        if let error {
            
            self.captureCompletion?(.failure(error))
            self.captureCompletion = nil
            
            return
            
        }
        
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else {
            
            self.captureCompletion?(.failure(CameraError.imageCreationFailed))
            self.captureCompletion = nil
            
            return
            
        }
        
        self.captureCompletion?(.success(image))
        self.captureCompletion = nil
        
    }
    
}

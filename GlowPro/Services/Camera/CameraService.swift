//
//  CameraService.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/30/25.
//

import Photos
import UIKit

final class CameraService: NSObject, CameraServiceProtocol {
    
    internal let loggerName: String = "CAMERA_SERVICE"
    internal let loggerEmoji: String = "📷"
    
    public let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    
    private let photoOutput = AVCapturePhotoOutput()
    private var videoDeviceInput: AVCaptureDeviceInput?
    private var captureCompletion: ((Result<UIImage, Error>) -> Void)?
    
    override init() {
        
        super.init()
        self.logInit()
        
    }
    
    deinit {
        self.logDeinit()
    }
    
    public func configure() throws {
        
        self.session.beginConfiguration()
        self.session.sessionPreset = .photo
        
        guard let device = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .back
        ) else {
            
            self.logger.error("Error: No wide angle camera found")
            self.session.commitConfiguration()
            throw CameraError.deviceUnavailable
            
        }
        
        let input = try AVCaptureDeviceInput(device: device)
        
        if self.session.canAddInput(input) {
            
            self.session.addInput(input)
            self.videoDeviceInput = input
            self.logger.log("Can add video device input")
            
        } else {
            
            self.logger.error("Error: Failed to add video device input")
            self.session.commitConfiguration()
            throw CameraError.inputAddFailed
            
        }
        
        if self.session.canAddOutput(self.photoOutput) {
            
            self.session.addOutput(self.photoOutput)
//            self.photoOutput.maxPhotoDimensions = .init(width: 1024, height: 1024)
            self.logger.log("Can add photo output")
            
        } else {
            
            self.logger.error("Error: Failed to add photo output")
            self.session.commitConfiguration()
            throw CameraError.outputAddFailed
            
        }
        
        self.session.commitConfiguration()
        
    }
    
    public func start() {
        
        self.sessionQueue.async { [weak self] in
            
            guard let strongSelf = self else { return }
            
            self?.logger.log("Attemping to start camera session...")
            
            if !strongSelf.session.isRunning {
                
                strongSelf.session.startRunning()
                self?.logger.log("Starting camera session...")
                
            }
            
        }
        
    }
    
    public func stop() {
        
        self.logger.log("Attemping to stop camera session...")
        
        self.sessionQueue.async { [weak self] in
            
            self?.session.stopRunning()
            self?.logger.log( "Stopping camera session...")
            
        }
        
    }
    
    public func capturePhoto(_ completion: @escaping (Result<UIImage, Error>) -> Void) {
        
        let settings = AVCapturePhotoSettings()
//        settings.maxPhotoDimensions = .init(width: 1024, height: 1024)
        
        self.captureCompletion = completion
        
        self.photoOutput.capturePhoto(
            with: settings,
            delegate: self
        )
        
        self.logger.log("Capturing photo...")
        
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

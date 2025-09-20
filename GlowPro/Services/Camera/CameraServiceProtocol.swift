//
//  CameraServiceProtocol.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/30/25.
//

import Photos
import UIKit
import Combine

public protocol CameraServiceProtocol: AnyObject, Loggable {
    
    var session: AVCaptureSession { get }
    
    var flashMode: CameraFlashMode { get }
    var flashModePublisher: AnyPublisher<CameraFlashMode, Never> { get }
    
    var zoomFactor: CGFloat { get set }
    var zoomFactorPublisher: AnyPublisher<CGFloat, Never> { get }
    
    func configure() throws
    
    func start()
    func stop()
    func teardown()
    
    func capturePhoto(_ completion: @escaping (Result<UIImage, Error>) -> Void)
    
    func setFlashMode(_ mode: CameraFlashMode)
    func toggleFlash()
    
    func setZoom(factor: CGFloat,
                 animated: Bool,
                 rampRate: Float)
    
    func zoom(by multiplier: CGFloat,
              animated: Bool)
    
    
}

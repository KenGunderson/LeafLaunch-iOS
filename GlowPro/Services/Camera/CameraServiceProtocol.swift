//
//  CameraServiceProtocol.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/30/25.
//

import Photos
import UIKit

public protocol CameraServiceProtocol: AnyObject, Loggable {
    
    var session: AVCaptureSession { get }
    
    func configure() throws
    func start()
    func stop()
    func capturePhoto(_ completion: @escaping (Result<UIImage, Error>) -> Void)
    
}

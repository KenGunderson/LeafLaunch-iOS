//
//  CameraPreviewView.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/30/25.
//

import AVFoundation
import SwiftUI

public struct CameraPreviewView: UIViewRepresentable {
    
    public let session: AVCaptureSession
    
    public func makeUIView(context: Context) -> Preview {
        
        let view = Preview()
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        
        return view
        
    }
    
    public func updateUIView(_ uiView: Preview, context: Context) {}
    
    public final class Preview: UIView {
        
        override public class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
        public var videoPreviewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
        
    }
    
}

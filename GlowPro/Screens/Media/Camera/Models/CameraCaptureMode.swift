//
//  CameraCaptureMode.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/30/25.
//

import UIKit

public enum CameraCaptureMode: Hashable, Sendable {
    
    case single(UIImage?)
    case multiple([UIImage])
    
    mutating func addPhoto(_ image: UIImage) {
        
        switch self {
        case .single:
            
            self = .single(image)
            
        case .multiple(var images):
            
            images.append(image)
            self = .multiple(images)
        }
        
    }
    
    var latestPhoto: UIImage? {
        
        switch self {
        case .single(let img): return img
        case .multiple(let imgs): return imgs.last
        }
        
    }
    
    var allPhotos: [UIImage] {
        
        switch self {
        case .single(let img): return img.map { [$0] } ?? []
        case .multiple(let imgs): return imgs
        }
        
    }
    
}

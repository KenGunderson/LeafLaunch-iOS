//
//  ImageSource.swift
//  Rune
//
//  Created by Sako Hovaguimian on 4/8/25.
//

import SwiftUI
import Kingfisher

enum ImageSource {
    
    case image(SwiftUI.ImageResource)
    case systemImage(String)
    
    case remote(url: URL,
                placeholder: AnyView? = nil,
                onSuccess: ((RetrieveImageResult) -> Void)? = nil,
                onFailure: ((Error) -> Void)? = nil)
    
    @MainActor
    @ViewBuilder
    func view() -> some View {
        
        switch self {
            
        case .image(let image):
            
            Image(image)
                .resizable()
            
        case .systemImage(let systemImage):
            
            Image(systemName: systemImage)
                .resizable()
            
        case .remote(let url, let placeholder, let onSuccess, let onFailure):
            
            KFImage(url)
                .resizable()
                .placeholder {
                    placeholder
                }
                .onSuccess { result in
                    onSuccess?(result)
                }
                .onFailure { error in
                    onFailure?(error)
                }
            
        }
        
    }
    
}

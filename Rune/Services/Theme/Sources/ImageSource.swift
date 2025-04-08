//
//  ImageSource.swift
//  Rune
//
//  Created by Sako Hovaguimian on 4/8/25.
//


import SwiftUI
import Kingfisher

enum ImageSource {
    
    case image(Image)
    
    case remote(url: URL,
                placeholder: AnyView? = nil,
                onSuccess: ((RetrieveImageResult) -> Void)? = nil,
                onFailure: ((Error) -> Void)? = nil)
    
    @MainActor
    @ViewBuilder
    func view() -> some View {
        
        switch self {
            
        case .image(let image):
            
            image
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

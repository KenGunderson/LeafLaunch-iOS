//
//  MediaURLPreviewView.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 9/26/25.
//

import SwiftUI

struct MediaURLPreviewView: View {
    
    public enum Context: Hashable {
        
        case url(url: URL)
        case uiImage(uiImage: UIImage)
        
    }
    
    @Environment(\.dismiss) private var dismiss
    
    let ctx: Context
    
    var body: some View {
        
        AppBaseView {
            
            ZoomView {
                
                switch ctx {
                    
                case .url(let url):
                    
                    ImageSource.remote(url: url)
                        .view()
                        .aspectRatio(contentMode: .fit)
                    
                case .uiImage(let uiImage):
                    
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    
                }

            }
            
        }
        .safeAreaInset(edge: .top) {
            navBar()
        }
        
    }
    
    private func navBar() -> some View {
        
        let closeButton = NavBarButton(style: .close) {
            self.dismiss()
        }
        .asAnyView()
        
        return NavBarView(
            title: "Preview",
            rightButtonView: closeButton
        )
        
    }
    
}

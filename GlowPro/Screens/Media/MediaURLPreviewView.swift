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
                    
                    DownsampledRemoteImage(
                        url: url,
                        targetSize: .init(
                            width: UIScreen.main.bounds.width,
                            height: UIScreen.main.bounds.height
                        ),
                        contentMode: .fit,
                        placeholder: PlaceholderView().asAnyView()
                    )
                    
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

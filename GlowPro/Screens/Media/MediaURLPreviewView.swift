//
//  MediaURLPreviewView.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 9/26/25.
//

import SwiftUI

struct MediaURLPreviewView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    let url: URL
    
    var body: some View {
        
        AppBaseView {
            
            ZoomView {
                
                ImageSource.remote(url: url)
                    .view()
                    .aspectRatio(contentMode: .fit)

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

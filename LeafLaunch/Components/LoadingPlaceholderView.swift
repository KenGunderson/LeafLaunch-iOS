//
//  LoadingPlaceholderView.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 9/8/25.
//

import SwiftUI

struct LoadingPlaceholderView: View {

    @Environment(\.style) private var style
    
    var body: some View {
            
        RoundedRectangle(cornerRadius: self.style.radius(.small))
            .fill(.background(.quaternary))
            .overlay {
                
                AppLoadingView(style: .circleRunner(
                    color: .background(.primary),
                    size: 24
                ))
                
            }
        
    }
    
}

#Preview {
    
    AppBaseView {
        
        LoadingPlaceholderView()
            .frame(
                width: 128,
                height: 128
            )
        
    }
    
}

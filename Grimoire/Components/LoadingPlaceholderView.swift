//
//  LoadingPlaceholderView.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 9/8/25.
//

import SwiftUI

struct LoadingPlaceholderView: View {
    
    var body: some View {
            
        RoundedRectangle(cornerRadius: Style.shared.radius(.small))
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

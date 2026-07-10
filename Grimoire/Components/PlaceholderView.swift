//
//  PlaceholderView.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 9/8/25.
//

import SwiftUI

struct PlaceholderView: View {
    
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

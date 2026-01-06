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
            .fill(Style.shared.background(.quaternary).source())
            .overlay {
                
                AppLoadingView(style: .circleRunner(
                    color: Style.shared.background(.primary),
                    size: 24
                ))
                
            }
        
    }
    
}
